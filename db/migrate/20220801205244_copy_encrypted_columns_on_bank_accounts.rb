class CopyEncryptedColumnsOnBankAccounts < ActiveRecord::Migration[7.0]
  def up
    BankAccount.update_all("encrypted_account_number_temp=encrypted_account_number")
    BankAccount.update_all("encrypted_account_number_temp_iv=encrypted_account_number_iv")
  end
end
