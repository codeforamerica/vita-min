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
FactoryBot.define do
  factory :state_file_nc1099_r_followup do
  end
end
