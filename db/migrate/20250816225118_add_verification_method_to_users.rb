class AddVerificationMethodToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :verification_method, :string
  end
end
