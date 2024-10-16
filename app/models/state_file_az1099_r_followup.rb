# == Schema Information
#
# Table name: state_file_az1099_r_followups
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StateFileAz1099RFollowup < ApplicationRecord

  has_one :state_file1099_r, inverse_of: :state_specific_followup

end