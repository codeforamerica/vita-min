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
require 'rails_helper'

RSpec.describe VitaPartnerStateRoutingFraction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
