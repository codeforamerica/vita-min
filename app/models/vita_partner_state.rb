# == Schema Information
#
# Table name: vita_partner_states
#
#  id               :bigint           not null, primary key
#  routing_fraction :float            default(0.0), not null
#  state            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  vita_partner_id  :bigint           not null
#
# Indexes
#
#  index_vita_partner_states_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class VitaPartnerState < ApplicationRecord
  belongs_to :vita_partner
  validate :invalid_state

  def balanced_routing_fraction
    (routing_fraction / VitaPartnerState.where(state: state).sum(:routing_fraction)).round(4)
  end

  def self.weighted_state_routing_ranges(state)
    routing_options_for_state = []
    VitaPartnerState.where(state: state).where.not(routing_fraction: 0.0).map do |vps|
      routing_options_for_state << [vps.vita_partner_id, vps.balanced_routing_fraction]
    end

    routing_ranges = []
    (0..routing_options_for_state.count - 1).each do |i|
      range = { id: routing_options_for_state[i][0] }
      if i.zero?
        range[:low] = 0.0
        range[:high] = routing_options_for_state[i][1]
      else
        range[:low] = routing_ranges[i-1][:high]
        range[:high] = i == routing_options_for_state.count - 1 ? 1.0 : range[:low] + routing_options_for_state[i][1]
      end
      routing_ranges << range
    end
    
    routing_ranges
  end

  private

  def invalid_state
    errors.add(:state, "Invalid state abbreviation") if States.name_for_key(state).nil?
  end
end
