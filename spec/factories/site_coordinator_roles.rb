# == Schema Information
#
# Table name: site_coordinator_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :site_coordinator_role do
    sites { [create(:site)] }
  end
end
