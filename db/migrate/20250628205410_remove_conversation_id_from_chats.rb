class RemoveConversationIdFromChats < ActiveRecord::Migration[8.0]
  def change
    remove_column :chats, :conversation_id, :integer
  end
end
