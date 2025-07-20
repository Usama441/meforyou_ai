class AddContactInputToUsers < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :contact, :phone
  end
end
