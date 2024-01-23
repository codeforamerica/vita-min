# == Schema Information
#
# Table name: abandoned_pre_consent_intakes
#
#  id                            :bigint           not null, primary key
#  intake_type                   :string
#  referrer                      :string
#  source                        :string
#  triage_filing_frequency       :integer
#  triage_filing_status          :integer
#  triage_income_level           :integer
#  triage_vita_income_ineligible :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  client_id                     :bigint
#  visitor_id                    :string
#
class AbandonedPreConsentIntake < ApplicationRecord
  enum triage_income_level: {
    "unfilled" => 0,
    "zero" => 1,
    "1_to_12500" => 2,
    "12500_to_25000" => 3,
    "25000_to_40000" => 4,
    "40000_to_66000" => 5,
    "66000_to_79000" => 6,
    "over_79000" => 7,
  }, _prefix: :triage_income_level
  enum triage_filing_status: { unfilled: 0, single: 1, jointly: 2 }, _prefix: :triage_filing_status
  enum triage_filing_frequency: { unfilled: 0, every_year: 1, some_years: 2, not_filed: 3 }, _prefix: :triage_filing_frequency
  enum triage_vita_income_ineligible: { unfilled: 0, yes: 1, no: 2 }, _prefix: :triage_vita_income_ineligible
end
