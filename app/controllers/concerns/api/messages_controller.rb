module Api
  class MessagesController < ApplicationController
    # Agar API public hai ya user authentication chahiye to yahan add kar sakte hain
    # before_action :authenticate_user!

    def index
      conversation = Conversation.find(params[:conversation_id])
      messages = conversation.messages.order(created_at: :asc)

      render json: messages.as_json(only: [:id, :content, :role, :created_at, :updated_at])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Conversation not found" }, status: :not_found
    end

    def create
      conversation = Conversation.find(params[:conversation_id])
      message = conversation.messages.build(message_params)

      if message.save
        render json: message.as_json(only: [:id, :content, :role, :created_at]), status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Conversation not found" }, status: :not_found
    end

    private

    def message_params
      params.require(:message).permit(:content, :role)
    end
  end
end
