class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
