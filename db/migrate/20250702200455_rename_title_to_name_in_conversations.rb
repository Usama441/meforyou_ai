class RenameTitleToNameInConversations < ActiveRecord::Migration[6.1]
  def change
    rename_column :conversations, :title, :name
  end
end