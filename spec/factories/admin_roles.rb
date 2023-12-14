# == Schema Information
#
# Table name: admin_roles
#
#  id         :bigint           not null, primary key
#  engineer   :boolean
#  state_file :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :admin_role do
  end
end
