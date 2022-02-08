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
class VitaPartner < ApplicationRecord
  TYPE = "VitaPartner"

  has_many :clients
  has_many :intakes
  has_many :source_parameters
  has_many :state_routing_fractions

  belongs_to :coalition, optional: true
  belongs_to :parent_organization, class_name: "Organization", optional: true

  scope :organizations, -> { where(type: Organization::TYPE) }
  scope :sites, -> { where(type: Site::TYPE) }
  scope :allows_greeters, lambda {
    greetable_organizations = where(allows_greeters: true)
    greetable_sites = where(parent_organization_id: greetable_organizations)
    greetable_organizations.or(greetable_sites)
  }

  accepts_nested_attributes_for :source_parameters, allow_destroy: true, reject_if: ->(attributes) { attributes['code'].blank? }

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

  def site?
    type == Site::TYPE
  end

  def organization?
    type == Organization::TYPE
  end

  # A VitaPartner is considered active if they have a StateRoutingFraction that is greater than 0 for any state.
  def active?
    StateRoutingFraction.where(vita_partner_id: id).where(StateRoutingFraction.arel_table[:routing_fraction].gt(0.0)).exists?
  end
end
