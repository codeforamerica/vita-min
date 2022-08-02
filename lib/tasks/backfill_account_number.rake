namespace :bank_account do
  desc "Backfill account number to new encrypted column"
  task backfill: :environment do
    BankAccount.where.not(encrypted_account_number: nil).find_each do |ba|
      if ba.read_attribute(:account_number).nil?
        ba.update_column(account_number: ba.attr_encrypted_account_number)
      end
    end
  end
end