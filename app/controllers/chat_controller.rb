require 'net/http'
require 'json'

class ChatController < ApplicationController
  include ActionController::Live
  before_action :authenticate_user!

  def new
    @chats = current_user.chats.order(created_at: :asc)
  end

  def create
    session_id = current_user.chat_sessions.last&.id

    if TopicClassifier.new_topic?(current_user, params[:message])
      new_session = ChatSession.create!(user: current_user, topic: "auto-generated")
      session_id = new_session.id
    end

    memory = RedisMemoryManager.new(current_user, session_id)
    memory.store_message("user", params[:message])

    tone = current_user.relationship.to_s.downcase
    PersonaManager.new(current_user).set("tone", tone)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = memory.get_history(20).map { |m| "#{m['role']}: #{m['content']}" }.join("\n")

    prompt = "#{persona}\n\nConversation:\n#{history}\n\nUser: #{params[:message]}\nAI:"
    reply = local_llama_response(prompt)

    memory.store_message("ai", reply)

    Chat.create!(
      user: current_user,
      chat_session_id: session_id,
      role: current_user.relationship,
      message: params[:message],
      reply: reply
    )

    redirect_to root_path, notice: "AI replied successfully."
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['X-Accel-Buffering'] = 'no'

    start_time = Time.now

    session_id = current_user.chat_sessions.last&.id
    memory = RedisMemoryManager.new(current_user, session_id)
    memory.store_message("user", params[:message])

    tone = current_user.relationship.to_s.downcase
    PersonaManager.new(current_user).set("tone", tone)

    persona = PersonaManager.new(current_user).all.map { |k, v| "#{k}: #{v}" }.join("\n")
    history = memory.get_history(100).map { |m| "#{m['role']}: #{m['content']}" }.join("\n")

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
        begin
          chunk.gsub!("data: ", "")
          Rails.logger.debug("🧩 Raw Chunk: #{chunk}")

          next if chunk.strip == "[DONE]"

          data = JSON.parse(chunk)

          # 🛡 Safety check
          delta = data.dig("choices", 0, "delta", "content")

          if delta.present?
            full_text += delta
            response.stream.write("data: #{ { response: delta }.to_json }\n\n")
          else
            Rails.logger.warn("⚠️ Unexpected data format: #{data.inspect}")
          end

        rescue => e
          Rails.logger.error("Stream parse error: #{e.message}")
        end
      end
    end

    Rails.logger.info "⏱ Streamed Response time: #{Time.now - start_time}s"

    if full_text.present?
      memory.store_message("ai", full_text)

      Chat.create!(
        user: current_user,
        chat_session_id: session_id,
        role: current_user.relationship,
        message: params[:message],
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
      http.request(req) do |response|
        response.read_body { |chunk| full_response += chunk }
      end
      json = JSON.parse(full_response) rescue nil
      json["choices"][0]["message"]["content"] || "Error: No content"
    rescue => e
      "Error: #{e.message}"
    end
  end

  def summarize_memory
    session_id = params[:session_id] || "default"
    summarizer = Summarizer.new(current_user, session_id)
    summarizer.summarize

    redirect_to chat_path, notice: "Memory summarized successfully."
  end
end
