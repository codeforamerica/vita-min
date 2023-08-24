# == Schema Information
#
# Table name: team_member_roles_vita_partners
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  team_member_role_id :bigint           not null
#  vita_partner_id     :bigint           not null
#
# Indexes
#
#  index_team_member_roles_vita_partners_on_team_member_role_id  (team_member_role_id)
#  index_team_member_roles_vita_partners_on_vita_partner_id      (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_member_role_id => team_member_roles.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class TeamMemberRolesVitaPartner < ApplicationRecord
  belongs_to :vita_partner
  belongs_to :site, foreign_key: "vita_partner_id", class_name: "Site"
  belongs_to :team_member_role
end
