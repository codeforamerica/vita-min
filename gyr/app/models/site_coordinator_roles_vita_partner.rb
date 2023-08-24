# == Schema Information
#
# Table name: site_coordinator_roles_vita_partners
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  site_coordinator_role_id :bigint           not null
#  vita_partner_id          :bigint           not null
#
# Indexes
#
#  index_scr_vita_partners_on_scr_id                              (site_coordinator_role_id)
#  index_site_coordinator_roles_vita_partners_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (site_coordinator_role_id => site_coordinator_roles.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class SiteCoordinatorRolesVitaPartner < ApplicationRecord
  belongs_to :vita_partner
  belongs_to :site, foreign_key: "vita_partner_id", class_name: "Site"
  belongs_to :site_coordinator_role
end
