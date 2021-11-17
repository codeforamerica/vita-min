# == Schema Information
#
# Table name: vita_partner_state_routing_fractions
#
#  id                      :bigint           not null, primary key
#  routing_fraction        :float            default(0.0), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_routing_target_id :bigint           not null
#  vita_partner_id         :bigint           not null
#
# Indexes
#
#  index_vita_partner_state_routing_fractions_on_vita_partner_id  (vita_partner_id)
#  index_vpsrf_on_state_routing_target_id                         (state_routing_target_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_routing_target_id => state_routing_targets.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :vita_partner_state_routing_fraction do
    vita_partner_id { nil }
    state_routing_target { nil }
    routing_fraction { 1.5 }
  end
end
