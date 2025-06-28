# db/migrate/20250628194245_add_conversation_to_chats.rb
class AddConversationToChats < ActiveRecord::Migration[7.1]
  def change
    add_reference :chats, :conversation, foreign_key: true # 🔁 remove `null: false`
  end
end
