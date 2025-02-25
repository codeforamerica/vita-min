# == Schema Information
#
# Table name: state_file_id1099_r_followups
#
#  id                     :bigint           not null, primary key
#  eligible_income_source :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class StateFileId1099RFollowup < ApplicationRecord

  has_one :state_file1099_r, inverse_of: :state_specific_followup

end
