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

    if request.headers["Turbo-Frame"]
      render partial: "chat/chat_exchange", locals: { chats: @chats, conversation: @conversation }
    else
      render :new
    end
  end

  def create
    conversation = current_user.conversations.find_by(id: params[:conversation_id]) ||
                   current_user.conversations.create(title: params[:ai_name], ai_name: params[:ai_name], relationship: params[:relationship])

    conversation.messages.create(content: params[:message], role: "user")
    conversation.messages.create(content: "AI is replying to: #{params[:message]}", role: "bot")

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

    Chat.create!(
      user: current_user,
      chat_session_id: session_id,
      conversation: conversation,
      role: "user",
      message: params[:message]
    )
    store_in_redis(conversation.id, role: "user", content: params[:message])

    Chat.create!(
      user: current_user,
      chat_session_id: session_id,
      conversation: conversation,
      role: tone,
      reply: reply
    )
    store_in_redis(conversation.id, role: tone, content: reply)

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

    uri = URI("http://localhost:11434/api/generate")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json"
    })

    req.body = {
      model: "mistral",
      prompt: prompt,
      stream: true
    }.to_json

    full_text = ""

    http.request(req) do |res|
      res.read_body do |chunk|
        begin
          data = JSON.parse(chunk) rescue nil
          delta = data["response"]
          next if delta.blank?

          full_text += delta
          response.stream.write("data: #{ { response: delta }.to_json }\n\n")
        rescue => e
          Rails.logger.error("Stream parse error: #{e.message} | Chunk: #{chunk}")
        end
      end
    end

    Rails.logger.info "⏱ Streamed Response time: #{Time.now - start_time}s"

    if full_text.present?
      memory.add_message(role: "ai", content: full_text)

      Chat.create!(
        user: current_user,
        chat_session_id: session_id,
        conversation: conversation,
        role: "user",
        message: params[:message]
      )
      store_in_redis(conversation.id, role: "user", content: params[:message])

      Chat.create!(
        user: current_user,
        chat_session_id: session_id,
        conversation: conversation,
        role: tone,
        reply: full_text
      )
      store_in_redis(conversation.id, role: tone, content: full_text)
    end

  rescue => e
    Rails.logger.error("Stream error: #{e.message}")
    response.stream.write("data: #{ { response: "[Error: #{e.message}]" }.to_json }\n\n")
  ensure
    response.stream.close
  end

  private

  def local_llama_response(prompt)
    uri = URI("http://localhost:11434/api/generate")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json"
    })

    req.body = {
      model: "mistral",
      prompt: prompt,
      stream: false
    }.to_json

    full_response = ""
    begin
      response = http.request(req)
      json = JSON.parse(response.body) rescue nil
      json["response"] || "Error: No content"
    rescue => e
      "Error: #{e.message}"
    end
  end

  def redis_chat_history(conversation_id)
    json = $redis.get("chat:history:#{conversation_id}")
    JSON.parse(json) rescue []
  end

  def store_in_redis(conversation_id, role:, content:)
    key = "chat:history:#{conversation_id}"
    history = ($redis.get(key).presence && JSON.parse($redis.get(key))) || []
    history << { role: role, content: content, timestamp: Time.now.to_s }
    $redis.set(key, history.to_json)
  end

  def summarize_memory
    conversation_id = params[:conversation_id]
    RedisMemoryService.new(conversation_id).reset!
    redirect_to chat_path(id: conversation_id), notice: "Memory reset successfully."
  end
end
