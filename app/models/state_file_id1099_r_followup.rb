# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                           :bigint           not null, primary key
#  civil_service_account_number :integer          default("unfilled"), not null
#  eligible_income_source       :integer          default("unfilled"), not null
#  firefighter_frf              :integer          default("unfilled"), not null
#  firefighter_persi            :integer          default("unfilled"), not null
#  income_source                :integer          default("unfilled"), not null
#  police_persi                 :integer          default("unfilled"), not null
#  police_retirement_fund       :integer          default("unfilled"), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class StateFileId1099RFollowup < ApplicationRecord

  has_one :state_file1099_r, inverse_of: :state_specific_followup

  enum eligible_income_source: { unfilled: 0, yes: 1, no: 2}, _prefix: :eligible_income_source
  enum income_source: { unfilled: 0, civil_service_employee: 1, police_officer: 2, firefighter: 3, military: 4, none: 5}, _prefix: :income_source
  enum civil_service_account_number: { unfilled: 0, zero_to_four: 1, seven_or_nine: 2, eight: 3}, _prefix: :civil_service_account_number
  enum police_retirement_fund: { unfilled: 0, yes: 1, no: 2}, _prefix: :police_retirement_fund
  enum police_persi: { unfilled: 0, yes: 1, no: 2}, _prefix: :police_persi
  enum firefighter_frf: { unfilled: 0, yes: 1, no: 2}, _prefix: :firefighter_frf
  enum firefighter_persi: { unfilled: 0, yes: 1, no: 2}, _prefix: :firefighter_persi

  def qualifying_retirement_income?
    if income_source_unfilled?
      return eligible_income_source_yes?
    end
    civil_service_qualified = income_source_civil_service_employee? && !civil_service_account_number_eight?

    police_qualified = income_source_police_officer? &&
                       (police_retirement_fund_yes? || police_persi_yes?)

    firefighter_qualified = income_source_firefighter? &&
                            (firefighter_frf_yes? || firefighter_persi_yes?)

    civil_service_qualified || police_qualified || firefighter_qualified || income_source_military?
  end
end
