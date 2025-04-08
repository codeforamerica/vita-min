# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                           :bigint           not null, primary key
#  civil_service_account_number :integer          default(0), not null
#  eligible_income_source       :integer          default("unfilled"), not null
#  firefighter_frf              :integer          default(0), not null
#  firefighter_persi            :integer          default(0), not null
#  income_source                :integer          default(0), not null
#  police_persi                 :integer          default(0), not null
#  police_retirement_fund       :integer          default(0), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class StateFileId1099RFollowup < ApplicationRecord

  has_one :state_file1099_r, inverse_of: :state_specific_followup

  enum eligible_income_source: { unfilled: 0, yes: 1, no: 2}, _prefix: :eligible_income_source
end
