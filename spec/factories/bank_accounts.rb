# == Schema Information
#
# Table name: bank_accounts
#
#  id                          :bigint           not null, primary key
#  _routing_number             :string
#  account_type                :integer
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  encrypted_routing_number    :string
#  encrypted_routing_number_iv :string
#  hashed_account_number       :string
#  hashed_routing_number       :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint
#
# Indexes
#
#  index_bank_accounts_on_hashed_account_number  (hashed_account_number)
#  index_bank_accounts_on_hashed_routing_number  (hashed_routing_number)
#  index_bank_accounts_on_intake_id              (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
FactoryBot.define do
  factory :bank_account do
    intake
    bank_name { "Self-help United" }
    routing_number { "123456789" }
    account_number { "87654321" }
    account_type { "checking" }
  end

  factory :empty_bank_account, class: "BankAccount" do
    intake
  end
end
