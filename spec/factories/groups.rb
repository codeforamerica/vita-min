# == Schema Information
#
# Table name: groups
#
#  id              :bigint           not null, primary key
#  description     :string
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_groups_on_organization_id  (organization_id)
#
FactoryBot.define do
  factory :group do
    organization
    name { "Aiport Tax Help Site" }
  end
end
