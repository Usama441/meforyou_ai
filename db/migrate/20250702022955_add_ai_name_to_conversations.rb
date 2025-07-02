class AddAiNameToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :ai_name, :string
  end
end
