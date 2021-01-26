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
    routing_fraction / VitaPartnerState.where(state: state).sum(:routing_fraction)
  end

  def state_routing_options
    routing_options = []
    VitaPartnerState.where(state: state).where.not(routing_fraction: 0.0).map do |vps|
      routing_options << [vps.vita_partner_id, vps.balanced_routing_fraction]
    end
    routing_ranges = []

    vita_partner_id = for i in 0..routing_options.count-1 do
      # between vps_options[i-1] && vps_options[i]
      if i == 0
        low_range = 0.0
        high_range = routing_options[i][1]
      else
        low_range = routing_options[i-1][1]
        high_range = routing_options[i][1]
      end
      routing_ranges << [routing_options[i][0], low_range, high_range]
    end

    routing_ranges
  end

  private

  def invalid_state
    errors.add(:state, "Invalid state abbreviation") if States.name_for_key(state).nil?
  end
end
