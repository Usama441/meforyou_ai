class AddVerificationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_verified, :boolean, default: false
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean, default: false
    add_column :users, :country_code, :string

    add_index :users, :phone_number
  end
end
