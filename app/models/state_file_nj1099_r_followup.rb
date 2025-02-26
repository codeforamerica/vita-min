# == Schema Information
#
# Table name: state_file_nj1099_r_followups
#
#  id            :bigint           not null, primary key
#  income_source :integer          default("unfilled"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class StateFileNj1099RFollowup < ApplicationRecord

  has_one :state_file1099_r, inverse_of: :state_specific_followup

  enum income_source: { unfilled: 0, military_pension: 1, military_survivors_benefits: 2, other: 3 }, _prefix: :income_source
end
