# == Schema Information
#
# Table name: organization_lead_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_organization_lead_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class OrganizationLeadRole < ApplicationRecord
  TYPE = "OrganizationLeadRole"

  belongs_to :organization, foreign_key: "vita_partner_id", class_name: "VitaPartner"
  validate :no_sites

  def served_entity
    organization
  end

  private

  def no_sites
    if organization.present? && organization.site?
      errors.add(:organization, "Organization lead role cannot contain a site")
    end
  end
end
