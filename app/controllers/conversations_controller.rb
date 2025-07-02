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
    current_user.update(ai_name: params[:ai_name], relationship: params[:relationship])

    # ✅ Also store ai_name and relationship in the conversation itself
    convo = current_user.conversations.create(
      title: params[:ai_name],
      ai_name: params[:ai_name],
      relationship: params[:relationship]
    )

    redirect_to chat_path(id: convo.id)
  end

end
