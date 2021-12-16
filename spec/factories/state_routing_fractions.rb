# == Schema Information
#
# Table name: state_routing_fractions
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
#  index_state_routing_fractions_on_state_routing_target_id  (state_routing_target_id)
#  index_state_routing_fractions_on_vita_partner_id          (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_routing_target_id => state_routing_targets.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :state_routing_fraction do
    routing_fraction { 0.2 }
  end
end
