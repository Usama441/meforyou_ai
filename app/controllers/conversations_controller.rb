class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = current_user.conversations.order(created_at: :desc)
    @conversation = current_user.conversations.new
  end

  def show
    @conversations = current_user.conversations.order(created_at: :desc)
    @conversation = current_user.conversations.find(params[:id])
    @message = Message.new
  end

  def create
    puts "===== DEBUG: Entered ConversationsController#create ====="

    puts "Params received:"
    puts params.inspect

    @conversation = current_user.conversations.new(conversation_params)

    puts "Conversation object after assignment:"
    puts @conversation.inspect

    if @conversation.save
      redirect_to chat_path, notice: "Conversation created."
    else
      render partial: "chat/modal", status: :unprocessable_entity
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:name, :relationship, :ai_status, :ai_gender, :ai_age, :description)

  end
end
