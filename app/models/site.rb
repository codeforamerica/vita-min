# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  accepts_itin_applicants    :boolean          default(FALSE)
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  coalition_id               :bigint
#  parent_organization_id     :bigint
#
# Indexes
#
#  index_vita_partners_on_coalition_id               (coalition_id)
#  index_vita_partners_on_parent_name_and_coalition  (parent_organization_id,name,coalition_id) UNIQUE
#  index_vita_partners_on_parent_organization_id     (parent_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#
class Site < VitaPartner
  TYPE = "Site"

  # Site records should not have an .organization_capacity but we want VitaPartner.includes(:organization_capacity) not to crash
  has_one :organization_capacity, foreign_key: "vita_partner_id"

  belongs_to :parent_organization, class_name: "Organization"
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode", foreign_key: "vita_partner_id"
  has_many :site_coordinator_roles, class_name: "SiteCoordinatorRole", foreign_key: "vita_partner_id", dependent: :destroy

  validates :name, uniqueness: { scope: [:parent_organization] }
  validate :no_coalitions
  validate :no_capacity
  validate :no_allows_greeters

  def coalition
    parent_organization.coalition
  end

  def at_capacity?
    parent_organization.at_capacity?
  end

  def allows_greeters?
    parent_organization.allows_greeters?
  end

  def site_coordinators
    User.where(role: SiteCoordinatorRole.where(site: self))
  end

  def team_members
    User.where(role: TeamMemberRole.where(site: self))
  end

  private

  def no_coalitions
    if coalition_id.present?
      errors.add(:coalition, "Sites cannot be direct members of coalitions")
    end
  end

  def no_capacity
    if capacity_limit.present?
      errors.add(:capacity_limit, "Sites cannot be assigned a capacity")
    end
  end

  def no_allows_greeters
    unless allows_greeters.nil?
      errors.add(:allows_greeters, "Allows greeters is set on an organization level and cannot be set on a site")
    end
  end
end
