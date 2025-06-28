require 'net/http'
require 'json'

class ChatController < ApplicationController
  include ActionController::Live
  before_action :authenticate_user!

  def new
    @chats = current_user.chats.order(created_at: :asc)
  end

  def create
    role_prompt = case current_user.relationship
                  when "mother"
                    "You are a loving son talking to his mother."
                  when "friend"
                    "You are a chill guy talking to your best friend."
                  when "partner"
                    "You are romantic and emotionally supportive."
                  else
                    "You are a calm, respectful person."
                  end

    prompt = "#{role_prompt}\nUser: #{params[:message]}\nAI:"
    reply = local_llama_response(prompt)

    if reply.present?
      Chat.create!(user: current_user, role: current_user.relationship, message: params[:message], reply: reply)
    end

    redirect_to root_path, notice: "AI replied successfully."
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['X-Accel-Buffering'] = 'no'

    role_prompt = case current_user.relationship
                  when "mother"
                    "You are a loving son talking to his mother."
                  when "friend"
                    "You are a chill guy talking to your best friend."
                  when "partner"
                    "You are romantic and emotionally supportive."
                  else
                    "You are a calm, respectful person."
                  end

    prompt = "#{role_prompt}\nUser: #{params[:message]}\nAI:"
    uri = URI('http://localhost:11434/api/generate')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    req.body = { model: "llama3", prompt: prompt, stream: true }.to_json

    full_text = ""

    http.request(req) do |res|
      res.read_body do |chunk|
        begin
          data = JSON.parse(chunk)
          if data["response"].present?
            full_text += data["response"]
            response.stream.write("data: #{ { response: data["response"] }.to_json }\n\n")
          end
        rescue => e
          Rails.logger.error("Stream JSON error: #{e.message}")
        end
      end
    end

    # ✅ Save full response to DB after generation
    if full_text.present?
      Chat.create!(
        user: current_user,
        role: current_user.relationship,
        message: params[:message],
        reply: full_text
      )
    end
  rescue => e
    Rails.logger.error("Stream failed: #{e.message}")
    response.stream.write("data: #{ { response: "[Error: #{e.message}]" }.to_json }\n\n")
  ensure
    response.stream.close
  end


  private

  def local_llama_response(prompt)
    uri = URI('http://localhost:11434/api/generate')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    req.body = { model: "llama3", prompt: prompt, stream: false }.to_json

    full_response = ""

    begin
      http.request(req) do |response|
        response.read_body do |chunk|
          full_response += chunk
        end
      end

      if full_response.present?
        json = JSON.parse(full_response)
        json["response"] || "I'm sorry, there was an error."
      else
        "Error: Empty response received."
      end
    rescue JSON::ParserError => e
      "Error parsing response: #{e.message}"
    rescue => e
      "Unexpected error: #{e.message}"
    end
  end
end
