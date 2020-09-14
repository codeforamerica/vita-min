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
class Group < ApplicationRecord
  belongs_to :organization
  has_many :clients, through: :group_assignment
  has_many :users, through: :group_membership
end
