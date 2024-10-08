# == Schema Information
#
# Table name: az321_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  charity_code            :string
#  charity_name            :string
#  date_of_contribution    :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az321_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
FactoryBot.define do
  factory :az321_contribution do
    date_of_contribution { Date.new(2023, 6, 4) }
    charity_code { 22541 }
    charity_name { "Center for Ants" }
    amount { 532.57 }
    state_file_az_intake
  end
end
