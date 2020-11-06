# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  archived                :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  weekly_capacity_limit   :integer
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_organization_id  :bigint
#  zendesk_group_id        :string           not null
#
# Indexes
#
#  index_vita_partners_on_parent_organization_id  (parent_organization_id)
#
class VitaPartner < ApplicationRecord
  DEFAULT_CAPACITY_LIMIT = 300

  has_many :clients
  has_many :intakes
  has_and_belongs_to_many :states, association_foreign_key: :state_abbreviation
  has_many :source_parameters
  has_many :users
  belongs_to :parent_organization, class_name: "VitaPartner", optional: true
  has_many :sub_organizations, -> { order(:id) }, class_name: "VitaPartner", foreign_key: "parent_organization_id"
  validate :one_level_of_depth

  scope :top_level, -> { where(parent_organization: nil).order(:display_name).order(:name) }

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

  private

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
