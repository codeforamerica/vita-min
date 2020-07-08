# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  weekly_capacity_limit   :integer
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
class VitaPartner < ApplicationRecord
  DEFAULT_CAPACITY_LIMIT = 300

  has_many :intakes
  has_and_belongs_to_many :states, association_foreign_key: :state_abbreviation
  has_many :source_parameters

  after_initialize :defaults

  def at_capacity?
    recently_consented_intakes_with_tickets.count >= weekly_capacity_limit
  end

  private

  def recently_consented_intakes_with_tickets
    intakes.where(
      Intake.arel_table[:primary_consented_to_service_at].gt(7.days.ago)
    ).where.not(intake_ticket_id: nil)
  end

  def defaults
    self.weekly_capacity_limit ||= DEFAULT_CAPACITY_LIMIT
  end
end
