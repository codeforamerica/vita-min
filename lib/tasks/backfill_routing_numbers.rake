namespace :routing_number do
  desc "backfill routing numbers"
  task backfill: :environment do
    BankAccount.where(_routing_number: nil).find_each do |ba|
      ba.update(_routing_number: ba.routing_number)
    end
  end
end