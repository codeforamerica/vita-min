# == Schema Information
#
# Table name: state_file_md1099_r_followups
#
#  id            :bigint           not null, primary key
#  income_source :integer          default("unfilled"), not null
#  service_type  :integer          default("unfilled"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class StateFileMd1099RFollowup < ApplicationRecord
  has_one :state_file1099_r, inverse_of: :state_specific_followup
  enum income_source: { unfilled: 0, pension_annuity_endowment: 1, other: 2 }, _prefix: :income_source
  enum service_type: { unfilled: 0, military: 1, public_safety: 2, none: 3 }, _prefix: :service_type
end
