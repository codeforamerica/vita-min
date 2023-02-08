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
#  name                       :citext           not null
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

  attribute :active_client_count

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
  scope :with_capacity, -> do
    not_these_states = ['intake_before_consent', 'intake_in_progress', 'intake_greeter_info_requested', 'intake_needs_doc_help', 'file_mailed', 'file_accepted', 'file_not_filing', 'file_hold', 'file_fraud_hold']
    with(
      organization_id_by_vita_partner_id: VitaPartner.select('id, (CASE WHEN parent_organization_id IS NULL THEN id ELSE parent_organization_id END) AS organization_id'),
      client_ids: TaxReturn.
        joins(:intake).
        select('client_id').
        where.not(current_state: not_these_states).
        where('intakes.product_year' => Rails.configuration.product_year),
      partner_and_client_counts: Arel.sql(<<~PACC)
        SELECT organization_id, count(clients.id) as active_client_count
        FROM organization_id_by_vita_partner_id
                 LEFT OUTER JOIN clients ON organization_id_by_vita_partner_id.id = clients.vita_partner_id
        WHERE clients.id IN (select client_id from client_ids) GROUP BY organization_id
    PACC
    ).joins('LEFT OUTER JOIN partner_and_client_counts ON vita_partners.id=partner_and_client_counts.organization_id')
     .select('vita_partners.*', 'CASE WHEN partner_and_client_counts.active_client_count IS NULL THEN 0 ELSE partner_and_client_counts.active_client_count END as active_client_count')
  end

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
