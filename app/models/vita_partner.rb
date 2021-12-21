# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string
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
class VitaPartner < ApplicationRecord
  self.inheritance_column = 'not_a_type_column'

  belongs_to :coalition, optional: true
  has_many :clients
  has_many :intakes
  has_many :source_parameters
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode"
  has_many :serviced_states, class_name: "VitaPartnerState"
  belongs_to :parent_organization, class_name: "VitaPartner", optional: true
  has_one :organization_capacity
  validate :one_level_of_depth
  validate :no_coalitions_for_sites
  validate :no_capacity_for_sites
  validate :no_allows_greeters_for_sites
  validates :name, uniqueness: { scope: [:coalition, :parent_organization] }
  validates :capacity_limit, gyr_numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  scope :organizations, -> { where(parent_organization: nil) }
  scope :sites, -> { where.not(parent_organization: nil) }
  has_many :child_sites, -> { order(:id) }, class_name: "VitaPartner", foreign_key: "parent_organization_id"
  scope :allows_greeters, -> {
    greetable_organizations = organizations.where(allows_greeters: true)
    greetable_sites = sites.where(parent_organization: greetable_organizations)
    greetable_organizations.or(greetable_sites)
  }

  default_scope { includes(:child_sites).order(name: :asc) }
  accepts_nested_attributes_for :source_parameters, allow_destroy: true, reject_if: lambda { |attributes| attributes['code'].blank? }

  def allows_greeters?
    return parent_organization.allows_greeters? if site?

    allows_greeters
  end

  def at_capacity?
    return parent_organization.at_capacity? if site?

    !OrganizationCapacity.with_capacity.where(vita_partner: self).exists?
  end

  def organization?
    parent_organization_id.blank?
  end

  def site?
    parent_organization_id.present?
  end

  def self.client_support_org
    # When a person messages us, but their contact info does not match any Client, link them to this org.
    VitaPartner.find_by!(name: "GYR National Organization")
  end

  def self.ctc_org
    VitaPartner.find_by!(name: "GetCTC.org")
  end

  def self.ctc_site
    VitaPartner.find_by!(name: "GetCTC.org (Site)")
  end

  def organization_leads
    User.where(role: OrganizationLeadRole.where(organization: self))
  end

  def site_coordinators
    User.where(role: SiteCoordinatorRole.where(site: organization? ? child_sites : self))
  end

  def team_members
    User.where(role: TeamMemberRole.where(site: organization? ? child_sites : self))
  end

  private

  def no_coalitions_for_sites
    if site? && coalition_id.present?
      errors.add(:coalition, "Sites cannot be direct members of coalitions")
    end
  end

  def no_capacity_for_sites
    if site? && capacity_limit.present?
      errors.add(:capacity_limit, "Sites cannot be assigned a capacity")
    end
  end

  def no_allows_greeters_for_sites
    if site? && !allows_greeters.nil?
      errors.add(:allows_greeters, "Allows greeters is set on an organization level and cannot be set on a site")
    end
  end

  def one_level_of_depth
    if parent_organization&.parent_organization.present?
      errors.add(:parent_organization, "Only one level of sub-organization depth allowed.")
    end
  end
end
