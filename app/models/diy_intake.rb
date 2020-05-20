# == Schema Information
#
# Table name: diy_intakes
#
#  id                 :bigint           not null, primary key
#  preferred_name     :string
#  state_of_residence :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class DiyIntake < ApplicationRecord
  
end
