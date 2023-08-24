# == Schema Information
#
# Table name: coalitions
#
#  id         :bigint           not null, primary key
#  name       :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_coalitions_on_name  (name) UNIQUE
#
class Coalition < ApplicationRecord
  TYPE = "Coalition"

  validates :name, uniqueness: true
  has_many :organizations, class_name: "Organization", foreign_key: "coalition_id"
  has_many :state_routing_targets, class_name: "StateRoutingTarget", as: :target, dependent: :destroy
end
