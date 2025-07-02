class AddTopicToChatSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_sessions, :topic, :string
  end
end
