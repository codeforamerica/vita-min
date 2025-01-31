# == Schema Information
#
# Table name: az322_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  ctds_code               :string
#  date_of_contribution    :date
#  district_name           :string
#  school_name             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az322_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
FactoryBot.define do
  factory :az322_contribution do
    date_of_contribution_year { Rails.configuration.statefile_current_tax_year }
    date_of_contribution_month { "3" }
    date_of_contribution_day { "4" }
    ctds_code { "100206038" }
    school_name { "Schublic Pool" }
    district_name { "Dool Schistrict" }
    amount { 302.45 }
  end
end
