class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    @message = @conversation.messages.create(
      content: params[:message][:content],
      role: "user"
    )

    # Trigger AI response (sync for now, we’ll stream later)
    ai_response = "This is a dummy AI response for now."
    @conversation.messages.create(content: ai_response, role: "ai")

    redirect_to conversation_path(@conversation)
  end
end
