class Site < VitaPartner
  TYPE = "Site"

  belongs_to :parent_organization, class_name: "Organization"
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode", foreign_key: "vita_partner_id"
  has_many :serviced_states, class_name: "VitaPartnerState", foreign_key: "vita_partner_id"

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
