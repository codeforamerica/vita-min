FactoryBot.define do
  factory :archived_2021_bank_account, class: Archived::BankAccount2021 do
    bank_name { "Self-help United" }
    routing_number { "123456789" }
    account_number { "87654321" }
    account_type { "checking" }
  end
end
