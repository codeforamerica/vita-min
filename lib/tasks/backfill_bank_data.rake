namespace :bank_account do
  desc "Backfill account number to new encrypted column"
  task backfill: :environment do
    BankAccount.where(bank_name: nil).or(BankAccount.where(account_number: nil)).find_each do |ba|
      if ba.read_attribute(:account_number).nil?
        ba.update_column(account_number: ba.attr_encrypted_account_number)
      end
      if ba.read_attribute(:bank_name).nil?
        ba.update_column(bank_name: ba.attr_encrypted_bank_name)
      end
    end
  end
end