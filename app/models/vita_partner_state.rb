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
#  index_vita_partner_states_on_state_and_vita_partner_id  (state,vita_partner_id) UNIQUE
#  index_vita_partner_states_on_vita_partner_id            (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class VitaPartnerState < ApplicationRecord
  belongs_to :vita_partner
  validate :invalid_state
  validates :state, uniqueness: { scope: :vita_partner_id }

  def balanced_routing_fraction
    (routing_fraction / VitaPartnerState.where(state: state).sum(:routing_fraction)).round(4)
  end

  def self.weighted_routing_ranges(vita_partner_states)
    routing_ranges = []
    vita_partner_states.each_with_index do |vps, i|
      next if vps.routing_fraction.zero?

      range = { id: vps.vita_partner_id }
      if i.zero?
        range[:low] = 0.0
        range[:high] = vps.balanced_routing_fraction
      else
        range[:low] = routing_ranges.last[:high]
        range[:high] = i == vita_partner_states.count - 1 ? 1.0 : range[:low] + vps.balanced_routing_fraction
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
