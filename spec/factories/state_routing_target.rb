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
FactoryBot.define do
  factory :state_routing_target do
    state { "CA" }
    vita_partner { build(:organization) }
  end
end
