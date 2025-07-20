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

    begin
      memory = RedisMemoryService.new(conversation.id)
      memory.add_message(role: "user", content: params[:message])
    rescue => e
      Rails.logger.error("Memory service error: #{e.message}")
      # Continue without memory service
    end

    tone = conversation.try(:relationship).presence || current_user.try(:relationship).presence || "neutral"
    ai_name = conversation.try(:ai_name).presence || current_user.try(:ai_name).presence || "AI"
    tone = tone.to_s.downcase

    PersonaManager.new(current_user).set("tone", tone)
    PersonaManager.new(current_user).set("ai_name", ai_name)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = []
    begin
      history = memory.get_prompt_context if memory.respond_to?(:get_prompt_context)
    rescue => e
      Rails.logger.error("Memory history error: #{e.message}")
      # Continue with empty history
    end

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

    # Extract message from different possible parameter formats
    user_message = params[:message] || params.dig(:chat, :message)
    conversation_id = params[:conversation_id] || params.dig(:chat, :conversation_id)

    conversation = current_user.conversations.find_by(id: conversation_id) || current_user.conversations.last
    session_id = current_user.chat_sessions.last&.id

    puts "📩 Processing message: #{user_message.inspect}"
    puts "🆔 For conversation: #{conversation.id}"

    user_message = params[:message] || params.dig(:chat, :message)

    begin
      memory = RedisMemoryService.new(conversation.id)
      memory.add_message(role: "user", content: user_message) if memory.respond_to?(:add_message)
    rescue => e
      Rails.logger.error("Memory service error: #{e.message}")
      # Continue without memory service
    end

    tone = conversation.try(:relationship).presence || current_user.try(:relationship).presence || "neutral"
    ai_name = conversation.try(:ai_name).presence || current_user.try(:ai_name).presence || "AI"
    tone = tone.to_s.downcase

    PersonaManager.new(current_user).set("tone", tone)
    PersonaManager.new(current_user).set("ai_name", ai_name)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = memory.get_prompt_context

    # Build chat messages
    messages = []

    # Add system message if persona is not blank
    messages << { role: "system", content: persona } unless persona.blank?

    # Add history messages if available
    messages += history if history.is_a?(Array) && history.any?

    # Always add the user message
    messages << { role: "user", content: user_message }

    uri = URI("https://api.groq.com/openai/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['GROQ_API_KEY']}"
    })

    req.body = {
      model: "gemma2-9b-it", # Use a more reliable model
      messages: messages,
      stream: true
    }.to_json

    puts "📤 Request payload: #{req.body}"

    full_text = ""

          puts "🌐 Making request to Groq API"
          http.request(req) do |res|
      puts "📥 Response status: #{res.code} #{res.message}"

      if res.code.to_i >= 400
        error_message = "Groq API error: #{res.code} #{res.message}"
        error_body = JSON.parse(res.body) rescue { "error" => "Unknown error" }
        detailed_error = "#{error_message} - #{error_body['error']['message']}" rescue error_message

        Rails.logger.error("API Error: #{detailed_error}")
        puts "🔥 Groq API Error: #{detailed_error}"
        puts "🔍 Request body: #{req.body}"

        response.stream.write("data: #{{ response: detailed_error, error: true }.to_json}\n\n")
        response.stream.flush
        return
      end

      res.read_body do |chunk|
        begin
          # Clean prefix like "data: ..."
          chunk.strip.split("\n").each do |line|
            next unless line.start_with?("data: ")
            begin
              json_data = JSON.parse(line.sub("data: ", ""))
              delta = json_data.dig("choices", 0, "delta", "content")
              puts "🔍 Groq Delta: #{delta.inspect}"
              next if delta.nil? || delta.empty?
            rescue => e
              puts "❌ Error parsing Groq chunk: #{e.message} | Line: #{line.inspect}"
              next
            end

            full_text += delta
            response_data = { response: delta }.to_json
            puts "📤 Sending stream data: #{response_data}"
            # Ensure proper format for EventSource parsing
            response.stream.write("data: #{response_data}\n\n")
            response.stream.flush
          end
        rescue => e
          Rails.logger.error("Groq stream parse error: #{e.message} | Chunk: #{chunk}")
        end
      end
    end

    Rails.logger.info "⏱ Streamed Response time: #{Time.now - start_time}s"

    if full_text.present?
      begin
        memory.add_message(role: "ai", content: full_text) if memory.respond_to?(:add_message)
      rescue => e
        Rails.logger.error("Memory add message error: #{e.message}")
        # Continue without memory service
      end

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
    error_message = "Groq Stream error: #{e.message} | #{e.backtrace.first(3).join(', ')}"
    Rails.logger.error(error_message)
    response_data = { response: "[Error: #{e.message}]", error: true }.to_json
    puts "📤 Sending error: #{response_data}"
    response.stream.write("data: #{response_data}\n\n")
    response.stream.flush
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
      "Authorization" => "Bearer #{ENV['GROQ_API_KEY']}"
    })

    req.body = {
      model: "gemma2-9b-it", # Use a more reliable model
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: prompt }
      ],
      stream: false
    }.to_json

    response = http.request(req)
    json = JSON.parse(response.body) rescue nil
    json["choices"][0]["message"]["content"] rescue "Error: No content"
  rescue => e
    "Error: #{e.message}"
  end

  def redis_chat_history(conversation_id)
    begin
      return [] unless $redis&.connected?
      json = $redis.get("chat:history:#{conversation_id}")
      JSON.parse(json) rescue []
    rescue => e
      Rails.logger.error("Redis chat history error: #{e.message}")
      return []
    end
  end

  def store_in_redis(conversation_id, role:, content:)
    begin
      key = "chat:history:#{conversation_id}"
      history = ($redis.get(key).presence && JSON.parse($redis.get(key))) || []
      history << { role: role, content: content, timestamp: Time.now.to_s }
      $redis.set(key, history.to_json)
    rescue Redis::CannotConnectError => e
      Rails.logger.error("Redis connection error: #{e.message}")
      # Continue without Redis to allow chat functionality to work
    rescue => e
      Rails.logger.error("Redis error: #{e.message}")
      # Continue without Redis to allow chat functionality to work
    end
  end

  def summarize_memory
    conversation_id = params[:conversation_id]
    RedisMemoryService.new(conversation_id).reset!
    redirect_to chat_path(id: conversation_id), notice: "Memory reset successfully."
  end
end
