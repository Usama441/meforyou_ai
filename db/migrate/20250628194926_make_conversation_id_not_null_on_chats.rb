
class MakeConversationIdNotNullOnChats < ActiveRecord::Migration[7.1]
  def change
    change_column_null :chats, :conversation_id, false
  end
end
