# == Schema Information
#
# Table name: bank_accounts
#
#  id                    :bigint           not null, primary key
#  account_number        :text
#  account_type          :integer
#  bank_name             :string
#  hashed_account_number :string
#  routing_number        :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  intake_id             :bigint
#
# Indexes
#
#  index_bank_accounts_on_hashed_account_number  (hashed_account_number)
#  index_bank_accounts_on_intake_id              (intake_id)
#  index_bank_accounts_on_routing_number         (routing_number)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
FactoryBot.define do
  factory :bank_account do
    intake
    bank_name { "Self-help United" }
    routing_number { "019456124" }
    account_number { "87654321" }
    account_type { "checking" }
  end

  factory :empty_bank_account, class: "BankAccount" do
    intake
  end
end
