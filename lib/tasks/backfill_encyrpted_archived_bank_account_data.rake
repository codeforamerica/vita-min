namespace :backfill do
  desc "Backfill attr_encrypted intake columns to new encrypted columns"
  task archvied_bank_account: :environment do
    Archived::BankAccount2021.find_each do |ba|
      ba.update(routing_number: ba.attr_encrypted_routing_number,
                account_number: ba.attr_encrypted_account_number,
                bank_name: ba.attr_encrypted_bank_name
      )
    end
  end
end