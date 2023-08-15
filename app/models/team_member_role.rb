# == Schema Information
#
# Table name: team_member_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TeamMemberRole < ApplicationRecord
  TYPE = "TeamMemberRole"

  has_many :team_member_roles_vita_partners, dependent: :destroy
  has_many :vita_partners, through: :team_member_roles_vita_partners
  has_many :sites, through: :team_member_roles_vita_partners
  validate :has_site
  validate :all_sites_in_same_org

  scope :assignable_to_sites, -> (sites) {
    left_outer_joins(:sites).where(vita_partners: sites)
  }

  def served_entities
    sites
  end

  private

  def has_site
    errors.add(:sites, "Must be associated to at least one site") if sites.blank?
  end

  def all_sites_in_same_org
    if sites.map(&:parent_organization).uniq.length > 1
      errors.add(:sites, "Must all be part of the same organization")
    end
  end
end
