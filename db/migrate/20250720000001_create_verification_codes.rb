class CreateVerificationCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :verification_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.boolean :used, default: false
      t.string :code_type, default: 'email_verification'

      t.timestamps
    end

    add_index :verification_codes, [:user_id, :code_type]
  end
end
