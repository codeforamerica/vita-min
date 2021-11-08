class Organization < VitaPartner
  belongs_to :coalition, optional: true
  has_one :organization_capacity
  has_many :child_sites, -> { order(:id) }, class_name: "Site", foreign_key: "parent_organization_id"

  validates :capacity_limit, gyr_numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  default_scope { includes(:child_sites).order(name: :asc) }

  alias_attribute :allows_greeters?, :allows_greeters


  def at_capacity?
    !OrganizationCapacity.with_capacity.where(vita_partner: self).exists?
  end

  def organization_leads
    User.where(role: OrganizationLeadRole.where(organization: self))
  end

  def site_coordinators
    User.where(role: SiteCoordinatorRole.where(site: child_sites))
  end

  def team_members
    User.where(role: TeamMemberRole.where(site: child_sites))
  end
end
