class AddDefaultToVerificationCodesUsed < ActiveRecord::Migration[8.0]
  def change
    # Ensure used column has default value
    change_column_default :verification_codes, :used, from: nil, to: false
  end
end
