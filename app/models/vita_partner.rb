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
  has_many :clients
  has_many :intakes
  has_many :source_parameters
  has_many :serviced_zip_codes, class_name: "VitaPartnerZipCode"
  has_many :serviced_states, class_name: "VitaPartnerState"

  validate :one_level_of_depth
  validates :name, uniqueness: { scope: [:coalition, :parent_organization] }

  scope :allows_greeters, -> {
    greetable_organizations = Organization.where(allows_greeters: true)
    greetable_sites = Site.where(parent_organization: greetable_organizations)
    greetable_organizations.or(greetable_sites)
  }

  accepts_nested_attributes_for :source_parameters, allow_destroy: true, reject_if: lambda { |attributes| attributes['code'].blank? }

  def one_level_of_depth
    if parent_organization&.parent_organization.present?
      errors.add(:parent_organization, "Only one level of sub-organization depth allowed.")
    end
  end
end
