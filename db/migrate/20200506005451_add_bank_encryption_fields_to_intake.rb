class AddBankEncryptionFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :encrypted_bank_name_iv, :string
    add_column :intakes, :encrypted_bank_routing_number_iv, :string
    add_column :intakes, :encrypted_bank_account_number_iv, :string
  end
end
