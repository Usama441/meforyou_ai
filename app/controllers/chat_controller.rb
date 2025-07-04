require 'net/http'
require 'json'

class ChatController < ApplicationController
  include ActionController::Live
  before_action :authenticate_user!
  def new
    @conversations = current_user.conversations.order(created_at: :desc)
    @conversation = current_user.conversations.find_by(id: params[:id]) || current_user.conversations.last || Conversation.new
    @chats = @conversation.persisted? ? @conversation.chats.order(:created_at) : []
    @messages = @conversation&.messages || []
    @chats = Chat.where(conversation_id: @conversation.id).order(:created_at)
    @ai_name = @conversation.name.presence

    # 👇 Add this condition
    if request.headers["Turbo-Frame"]
      render partial: "chat/chat_exchange", locals: { chats: @chats, conversation: @conversation }
    else
      render :new
    end
  end


  def create
    conversation = current_user.conversations.find_by(id: params[:conversation_id]) ||
                   current_user.conversations.create(title: params[:ai_name], ai_name: params[:ai_name], relationship: params[:relationship])

    conversation.messages.create(content: params[:prompt], role: "user")
    conversation.messages.create(content: "AI is replying to: #{params[:prompt]}", role: "bot")

    session_id = current_user.chat_sessions.last&.id
    if TopicClassifier.new_topic?(current_user, params[:message])
      new_session = ChatSession.create!(user: current_user, topic: "auto-generated")
      session_id = new_session.id
    end

    memory = RedisMemoryService.new(conversation.id)
    memory.add_message(role: "user", content: params[:message])

    tone = conversation.try(:relationship).presence || current_user.try(:relationship).presence || "neutral"
    ai_name = conversation.try(:ai_name).presence || current_user.try(:ai_name).presence || "AI"
    tone = tone.to_s.downcase

    PersonaManager.new(current_user).set("tone", tone)
    PersonaManager.new(current_user).set("ai_name", ai_name)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = memory.get_prompt_context

    prompt = "#{persona}\n\nConversation:\n#{history}\n\nUser: #{params[:message]}\nAI:"
    reply = local_llama_response(prompt)

    memory.add_message(role: "ai", content: reply)

    # ✅ Save USER message
    Chat.create!(
      user: current_user,
      chat_session_id: session_id,
      conversation: conversation,
      role: "user",
      message: params[:message]
    )

    # ✅ Save AI message with correct name
    Chat.create!(
      user: current_user,
      chat_session_id: session_id,
      conversation: conversation,
      role: tone, # this can be "friend", "mother", etc.
      reply: reply
    )

    redirect_to chat_path(id: conversation.id), notice: "AI replied successfully."
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['X-Accel-Buffering'] = 'no'

    start_time = Time.now
    conversation = current_user.conversations.find_by(id: params[:conversation_id]) || current_user.conversations.last
    session_id = current_user.chat_sessions.last&.id

    memory = RedisMemoryService.new(conversation.id)
    memory.add_message(role: "user", content: params[:message])

    tone = conversation.try(:relationship).presence || current_user.try(:relationship).presence || "neutral"
    ai_name = conversation.try(:ai_name).presence || current_user.try(:ai_name).presence || "AI"
    tone = tone.to_s.downcase

    PersonaManager.new(current_user).set("tone", tone)
    PersonaManager.new(current_user).set("ai_name", ai_name)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = memory.get_prompt_context

    prompt = "#{persona}\n\nConversation:\n#{history}\n\nUser: #{params[:message]}\nAI:"
    Rails.logger.info "🔍 Streamed Prompt Sent:\n#{prompt}"

    uri = URI("https://api.groq.com/openai/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Rails.application.credentials[:groq_api_key]}"
    })

    req.body = {
      model: "llama3-8b-8192",
      messages: [
        { role: "system", content: persona },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      top_p: 0.9,
      max_tokens: 150,
      stream: true
    }.to_json

    full_text = ""

    http.request(req) do |res|
      res.read_body do |chunk|
        chunk.lines.each do |line|
          next unless line.start_with?("data:")
          json_str = line.sub("data:", "").strip
          next if json_str == "[DONE]"

          begin
            data = JSON.parse(json_str)
            delta = data.dig("choices", 0, "delta", "content")
            next if delta.nil? || delta.strip.empty?

            full_text += delta
            response.stream.write("data: #{ { response: delta }.to_json }\n\n")
          rescue => e
            Rails.logger.error("Stream parse error: #{e.message} | Chunk: #{json_str}")
          end
        end
      end
    end

    Rails.logger.info "⏱ Streamed Response time: #{Time.now - start_time}s"

    if full_text.present?
      memory.add_message(role: "ai", content: full_text)

      # ✅ Save USER message
      Chat.create!(
        user: current_user,
        chat_session_id: session_id,
        conversation: conversation,
        role: "user",
        message: params[:message]
      )

      # ✅ Save AI message
      Chat.create!(
        user: current_user,
        chat_session_id: session_id,
        conversation: conversation,
        role: tone, # "mother", "AI", etc.
        reply: full_text
      )
    end

  rescue => e
    Rails.logger.error("Stream error: #{e.message}")
    response.stream.write("data: #{ { response: "[Error: #{e.message}]" }.to_json }\n\n")
  ensure
    response.stream.close
  end

  private

  def local_llama_response(prompt)
    uri = URI("https://api.groq.com/openai/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{Rails.application.credentials[:groq_api_key]}"
    })

    req.body = {
      model: "llama3-8b-8192",
      messages: [
        { role: "system", content: "You are a friendly assistant." },
        { role: "user", content: prompt }
      ],
      temperature: 0.7,
      top_p: 0.9,
      max_tokens: 150,
      stream: false
    }.to_json

    full_response = ""
    begin
      http.request(req) { |response| response.read_body { |chunk| full_response += chunk } }
      json = JSON.parse(full_response) rescue nil
      json["choices"][0]["message"]["content"] || "Error: No content"
    rescue => e
      "Error: #{e.message}"
    end
  end

  def summarize_memory
    conversation_id = params[:conversation_id]
    RedisMemoryService.new(conversation_id).reset!
    redirect_to chat_path(id: conversation_id), notice: "Memory reset successfully."
  end
end
