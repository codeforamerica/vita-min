# == Schema Information
#
# Table name: coalitions
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_coalitions_on_name  (name) UNIQUE
#
class Coalition < ApplicationRecord
  validates :name, uniqueness: true
  # Use the VitaPartner.organizations scope to ensure we only find Organizations, not Sites.
  has_many :organizations, -> { organizations }, class_name: "VitaPartner", foreign_key: "coalition_id"
end
