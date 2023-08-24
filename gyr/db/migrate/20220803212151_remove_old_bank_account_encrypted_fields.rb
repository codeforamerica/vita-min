class RemoveOldBankAccountEncryptedFields < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :bank_accounts, :encrypted_account_number, :string
      remove_column :bank_accounts, :encrypted_account_number_iv, :string
      remove_column :bank_accounts, :encrypted_bank_name, :string
      remove_column :bank_accounts, :encrypted_bank_name_iv, :string
    end
  end
end
