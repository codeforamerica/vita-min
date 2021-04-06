# == Schema Information
#
# Table name: greeter_organization_join_records
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  greeter_role_id :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_greeter_organization_join_records_on_greeter_role_id  (greeter_role_id)
#  index_greeter_organization_join_records_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (greeter_role_id => greeter_roles.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
# TODO: delete
class GreeterOrganizationJoinRecord < ApplicationRecord
  # This model exists solely to support GreeterRole.
  belongs_to :greeter_role
  belongs_to :organization, foreign_key: "vita_partner_id", class_name: "VitaPartner"
  validate :no_sites

  private

  def no_sites
    if organization.present? && organization.site?
      errors.add(:organization, "Cannot contain a site")
    end
  end
end
