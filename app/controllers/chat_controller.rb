require 'net/http'
require 'json'

class ChatController < ApplicationController
  before_action :authenticate_user!

  def new
    @chats = current_user.chats.order(created_at: :desc).limit(10)
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

  private

  def local_llama_response(prompt)
    uri = URI('http://localhost:11434/api/generate')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    req.body = { model: "llama3", prompt: prompt, stream: false }.to_json
    res = http.request(req)
    json = JSON.parse(res.body)
    json["response"] rescue "I'm sorry, there was an error."
  end
end