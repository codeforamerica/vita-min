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
  belongs_to :organization, optional: true, foreign_key: 'vita_partner_id', class_name: 'Organization'
  belongs_to :site, optional: true, foreign_key: 'vita_partner_id', class_name: 'Site'
  validate :invalid_state
  validates :state, uniqueness: { scope: :vita_partner_id }

  def routing_percentage
    (routing_fraction * 100).to_i
  end

  private

  def invalid_state
    errors.add(:state, "Invalid state abbreviation") if States.name_for_key(state).nil?
  end
end
