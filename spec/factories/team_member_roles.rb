# == Schema Information
#
# Table name: team_member_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :team_member_role do
    sites { [create(:site)] }
  end
end
