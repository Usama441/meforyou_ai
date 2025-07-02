class AddChatSessionIdToChats < ActiveRecord::Migration[8.0]
  def change
    add_reference :chats, :chat_session, null: true, foreign_key: true
  end
end
