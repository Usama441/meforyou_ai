class AddDetailsToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :ai_status, :string
    add_column :conversations, :ai_gender, :string
    add_column :conversations, :ai_age, :integer
    add_column :conversations, :description, :text
  end
end
