# == Schema Information
#
# Table name: state_file_nj_staff_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StateFileNjStaffRole < ApplicationRecord
  TYPE = "StateFileNjStaffRole"
end
