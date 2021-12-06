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
#  index_state_routing_targets_on_state_abbreviation  (state_abbreviation)
#  index_state_routing_targets_on_target              (target_type,target_id)
#
class StateRoutingTarget < ApplicationRecord
  belongs_to :target, polymorphic: true
  validate :invalid_state

  def routing_percentage
    (routing_fraction * 100).to_i
  end

  private

  def invalid_state
    errors.add(:state, "Invalid state abbreviation") if States.name_for_key(state).nil?
  end
end
