# == Schema Information
#
# Table name: vita_partners
#
#  id                     :bigint           not null, primary key
#  accepts_overflow       :boolean          default(FALSE)
#  archived               :boolean          default(FALSE)
#  logo_path              :string
#  name                   :string           not null
#  weekly_capacity_limit  :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  coalition_id           :bigint
#  parent_organization_id :bigint
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
  DEFAULT_CAPACITY_LIMIT = 300

  belongs_to :coalition, optional: true
  has_many :clients
  has_many :intakes
  has_many :source_parameters
  has_many :users
  belongs_to :parent_organization, class_name: "VitaPartner", optional: true
  validate :one_level_of_depth
  validate :no_coalitions_for_sites
  validates :name, uniqueness: { scope: [:coalition, :parent_organization] }

  scope :organizations, -> { where(parent_organization: nil) }
  scope :sites, -> { where.not(parent_organization: nil) }
  has_many :child_sites, -> { order(:id) }, class_name: "VitaPartner", foreign_key: "parent_organization_id"

  default_scope { includes(:child_sites) }

  after_initialize :defaults

  def at_capacity?
    actionable_intakes_this_week.count >= weekly_capacity_limit
  end

  def has_capacity_for?(intake)
    if intake.vita_partner.name == "Urban Upbound (NY)"
      return urban_upbound_has_capacity_for? intake
    end
    !at_capacity?
  end

  def organization?
    parent_organization_id.blank?
  end

  def site?
    parent_organization_id.present?
  end

  private

  def no_coalitions_for_sites
    if site? && coalition_id.present?
      errors.add(:coalition, "Sites cannot be direct members of coalitions")
    end
  end

  def one_level_of_depth
    if parent_organization&.parent_organization.present?
      errors.add(:parent_organization, "Only one level of sub-organization depth allowed.")
    end
  end

  def urban_upbound_has_capacity_for?(intake)
    return true if ["source_parameter", "state"].include? intake.routing_criteria
    actionable_overflow_intakes_this_week.count < 50
  end

  def actionable_overflow_intakes_this_week
    actionable_intakes_this_week.where(routing_criteria: "overflow")
  end

  def actionable_intakes_this_week
    intakes.where(
      Intake.arel_table[:primary_consented_to_service_at].gt(7.days.ago),
    ).where.not(intake_ticket_id: nil)
  end

  def defaults
    self.weekly_capacity_limit ||= DEFAULT_CAPACITY_LIMIT
  end
end
