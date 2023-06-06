# == Schema Information
#
# Table name: team_member_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint
#
# Indexes
#
#  index_team_member_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class TeamMemberRole < ApplicationRecord
  TYPE = "TeamMemberRole"

  has_many :team_member_roles_vita_partners
  has_many :vita_partners, through: :team_member_roles_vita_partners
  has_many :sites, through: :team_member_roles_vita_partners
  validate :has_site

  def sites
    if vita_partner_id
      [VitaPartner.find(vita_partner_id)]
    else
      super
    end
  end

  def served_entity
    site
  end

  private

  def has_site
    errors.add(:sites, "Must be associated to at least one site") if sites.blank?
  end
end

