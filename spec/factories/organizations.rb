# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  coalition_id :bigint
#
# Indexes
#
#  index_organizations_on_coalition_id  (coalition_id)
#  index_organizations_on_name          (name) UNIQUE
#
FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Organization #{n}" }
  end
end
