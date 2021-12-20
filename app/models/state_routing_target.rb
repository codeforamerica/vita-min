# == Schema Information
#
# Table name: state_routing_targets
#
#  id                 :bigint           not null, primary key
#  state_abbreviation :string           not null
#  target_type        :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  target_id          :bigint           not null
#
# Indexes
#
#  index_state_routing_targets_on_target  (target_type,target_id)
#
class StateRoutingTarget < ApplicationRecord
  belongs_to :target, polymorphic: true

  validates :state_abbreviation, uniqueness: { scope: [:target] }
  validate :valid_state_abbreviation

  def routing_percentage
    (routing_fraction * 100).to_i
  end

  def full_state_name
    States.name_for_key(state_abbreviation)
  end

  private

  def valid_state_abbreviation
    errors.add(:state_abbreviation, "Invalid state abbreviation") if States.name_for_key(state_abbreviation).nil?
  end
end
