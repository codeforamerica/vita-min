class AddTempEncryptedBankNumber < ActiveRecord::Migration[7.0]
  def change
    add_column :bank_accounts, :account_number_temp, :string
    add_column :bank_accounts, :account_number_temp_iv, :string
  end
end
