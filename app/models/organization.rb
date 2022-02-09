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
class Organization < VitaPartner
  TYPE = "Organization"

  belongs_to :coalition, optional: true
  has_one :organization_capacity, foreign_key: "vita_partner_id"
  has_many :child_sites, -> { order(:id) }, class_name: "Site", foreign_key: "parent_organization_id"
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode", foreign_key: "vita_partner_id"
  has_many :state_routing_targets, as: :target
  validates :capacity_limit, gyr_numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :name, uniqueness: { scope: [:coalition] }
  has_many :state_routing_targets, as: :target, dependent: :destroy
  validate :no_state_routing_targets_if_in_coalition

  default_scope -> { includes(:child_sites).order(name: :asc) }
  alias_attribute :allows_greeters?, :allows_greeters

  def at_capacity?
    !OrganizationCapacity.with_capacity.where(organization: self).exists?
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

  private

  def no_state_routing_targets_if_in_coalition
    if coalition.present? && state_routing_targets.present?
      errors.add(:coalition, "Since the organization has states configured, it cannot also be part of a coalition.")
    end
  end
end
