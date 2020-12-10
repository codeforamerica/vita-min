# == Schema Information
#
# Table name: sites
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_sites_on_organization_id           (organization_id)
#  index_sites_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Site < ApplicationRecord
  belongs_to :organization
  
  validates :name, uniqueness: { scope: :organization }
end
