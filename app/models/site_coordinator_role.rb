# == Schema Information
#
# Table name: site_coordinator_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_site_coordinator_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class SiteCoordinatorRole < ApplicationRecord
  TYPE = "SiteCoordinatorRole"

  belongs_to :site, foreign_key: "vita_partner_id", class_name: "VitaPartner"
  validate :no_organizations

  def served_entity
    site
  end

  private

  def no_organizations
    if site.present? && site.organization?
      errors.add(:site, "Site coordinator role cannot contain an organization")
    end
  end
end
