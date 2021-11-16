# == Schema Information
#
# Table name: state_routing_targets
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
#  index_state_routing_targets_on_state_and_vita_partner_id  (state,vita_partner_id) UNIQUE
#  index_state_routing_targets_on_vita_partner_id            (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe StateRoutingTarget, type: :model do
  describe "validations" do
    context "with vita partner and valid state abbreviation" do
      it "is valid" do
        state_routing_target = described_class.new(state: "RI", vita_partner: create(:organization))

        expect(state_routing_target).to be_valid
      end
    end

    context "no vita partner" do
      it "is not valid" do
        state_routing_target = described_class.new(state: "RI")

        expect(state_routing_target).not_to be_valid
        expect(state_routing_target.errors).to include :vita_partner
      end
    end

    context "invalid state abbreviation" do
      it "is not valid" do
        state_routing_target = described_class.new(state: "TW", vita_partner: create(:organization))

        expect(state_routing_target).not_to be_valid
        expect(state_routing_target.errors).to include :state
      end
    end

    context "record with duplicate state and vita partner information" do
      let!(:vps) { create :state_routing_target, state: "OK" }

      it "is not valid" do
        duplicate_vps = described_class.new(state: "OK", vita_partner: vps.vita_partner)

        expect(duplicate_vps).not_to be_valid
      end
    end
  end
end
