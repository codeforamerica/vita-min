# == Schema Information
#
# Table name: state_file_nc1099_r_followups
#
#  id                                     :bigint           not null, primary key
#  bailey_settlement_at_least_five_years  :integer          default("unfilled"), not null
#  bailey_settlement_from_retirement_plan :integer          default("unfilled"), not null
#  income_source                          :integer          default("unfilled"), not null
#  uniformed_services_qualifying_plan     :integer          default("unfilled"), not null
#  uniformed_services_retired             :integer          default("unfilled"), not null
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#
class StateFileNc1099RFollowup < ApplicationRecord
  has_one :state_file1099_r, inverse_of: :state_specific_followup

  enum income_source: { unfilled: 0, bailey_settlement: 1, uniformed_services: 2, other: 3 }, _prefix: :income_source
  enum bailey_settlement_at_least_five_years: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bailey_settlement_at_least_five_years
  enum bailey_settlement_from_retirement_plan: { unfilled: 0, yes: 1, no: 2 }, _prefix: :bailey_settlement_from_retirement_plan
  enum uniformed_services_retired: { unfilled: 0, yes: 1, no: 2 }, _prefix: :uniformed_services_retired
  enum uniformed_services_qualifying_plan: { unfilled: 0, yes: 1, no: 2 }, _prefix: :uniformed_services_qualifying_plan
end
