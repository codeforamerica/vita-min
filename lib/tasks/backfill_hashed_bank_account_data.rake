namespace :bank_accounts do
  desc "Backfill hashed bank account data onto efile security information objects"
  task backfill: :environment do
    BankAccount.where(hashed_account_number: nil).or(BankAccount.where(hashed_routing_number:nil)).find_each do |account|
      columns = {}
      unless account.hashed_account_number.present?
        columns[:hashed_account_number] = HashAttribute.hmac_hexdigest(account.account_number)
      end
      unless account.hashed_routing_number.present?
        columns[:hashed_routing_number] = HashAttribute.hmac_hexdigest(account.routing_number)
      end
      unless columns.keys.length.empty?
        bank_account.update_columns(columns)
      end
    end
  end
end