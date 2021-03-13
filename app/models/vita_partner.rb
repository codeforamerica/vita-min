# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
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
  belongs_to :coalition, optional: true
  has_many :clients
  has_many :intakes
  has_many :source_parameters
  has_many :users
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode"
  has_many :serviced_states, class_name: "VitaPartnerState"
  belongs_to :parent_organization, class_name: "VitaPartner", optional: true
  has_one :organization_capacity
  validate :one_level_of_depth
  validate :no_coalitions_for_sites
  validate :no_capacity_for_sites
  validates :name, uniqueness: { scope: [:coalition, :parent_organization] }
  validates :capacity_limit, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  scope :organizations, -> { where(parent_organization: nil) }
  scope :sites, -> { where.not(parent_organization: nil) }
  has_many :child_sites, -> { order(:id) }, class_name: "VitaPartner", foreign_key: "parent_organization_id"

  default_scope { includes(:child_sites).order(name: :asc) }
  accepts_nested_attributes_for :source_parameters, allow_destroy: true, reject_if: lambda { |attributes| attributes['code'].blank? }

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

  def one_level_of_depth
    if parent_organization&.parent_organization.present?
      errors.add(:parent_organization, "Only one level of sub-organization depth allowed.")
    end
  end
end
