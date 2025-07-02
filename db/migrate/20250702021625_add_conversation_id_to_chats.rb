class AddConversationIdToChats < ActiveRecord::Migration[8.0]
  def change
    add_reference :chats, :conversation, null: true, foreign_key: true

  end
end
