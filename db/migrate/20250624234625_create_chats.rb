class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.string :message
      t.text :reply

      t.timestamps
    end
  end
end
