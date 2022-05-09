namespace :routing_number do
  desc "backfill routing numbers"
  task backfill: :environment do
    BankAccount.where.not(_routing_number: nil).find_each do |ba|
      ba.update(routing_number: ba._routing_number) unless ba.routing_number.present?
    end
  end
end