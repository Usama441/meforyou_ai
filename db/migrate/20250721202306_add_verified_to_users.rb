class AddVerifiedToUsers < ActiveRecord::Migration[8.0]
  def change
    # db/migrate/xxxxxx_add_verified_to_users.rb
    add_column :users, :verified, :boolean, default: false
  end
end
