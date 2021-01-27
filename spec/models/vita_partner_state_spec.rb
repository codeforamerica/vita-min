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
require 'rails_helper'

RSpec.describe VitaPartnerState, type: :model do
  describe "validations" do
    context "with vita partner and valid state abbreviation" do
      it "is valid" do
        vita_partner_state = described_class.new(state: "RI", vita_partner: create(:vita_partner))

        expect(vita_partner_state).to be_valid
      end
    end

    context "no vita partner" do
      it "is not valid" do
        vita_partner_state = described_class.new(state: "RI")

        expect(vita_partner_state).not_to be_valid
        expect(vita_partner_state.errors).to include :vita_partner
      end
    end

    context "invalid state abbreviation" do
      it "is not valid" do
        vita_partner_state = described_class.new(state: "TW", vita_partner: create(:vita_partner))

        expect(vita_partner_state).not_to be_valid
        expect(vita_partner_state.errors).to include :state
      end
    end
  end

  describe "#balanced_routing_fraction" do
    let!(:vps_1) { create :vita_partner_state, routing_fraction: 0.7, state: "RI" }
    let!(:vps_2) { create :vita_partner_state, routing_fraction: 0.4, state: "RI" }
    let!(:vps_3) { create :vita_partner_state, routing_fraction: 0.5, state: "NC" }

    it "returns the balanced routing fraction based on the other vita partners in state" do
      expect(vps_1.balanced_routing_fraction).to eq 0.6363636363636362
      expect(vps_2.balanced_routing_fraction).to eq 0.36363636363636365
      expect(vps_3.balanced_routing_fraction).to eq 1.0
    end

    context "when all fractions in the state are zero" do
      let!(:first_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }
      let!(:second_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }

      it "returns zero" do
        expect(first_vps.balanced_routing_fraction).to eq 0.0
        expect(second_vps.balanced_routing_fraction).to eq 0.0
      end
    end
  end

  describe ".weighted_state_routing_ranges" do
    context "when there are vita partners for state" do
      context "when all the vita partners have a value of 0 for routing fraction" do
        let!(:first_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }
        let!(:second_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }
        let!(:third_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }

        it "returns an empty array" do
          expect(VitaPartnerState.weighted_state_routing_ranges("RI")).to eq []
        end
      end

      context "when there are multiple vita partners with different routing fractions" do
        let!(:first_vps) { create :vita_partner_state, routing_fraction: 0.2, state: "RI" }
        let!(:second_vps) { create :vita_partner_state, routing_fraction: 0.9, state: "RI" }
        let!(:third_vps) { create :vita_partner_state, routing_fraction: 0.0, state: "RI" }
        let!(:out_of_state_vps) { create :vita_partner_state, routing_fraction: 0.9, state: "MD" }

        it "returns an array with vita partner ids and routing fraction range for all vita partners in that state" do
          expected_array = [
            {
              id: first_vps.vita_partner_id,
              low: 0.0,
              high: 0.18181818181818182
            },
            {
              id: second_vps.vita_partner_id,
              low: 0.18181818181818182,
              high: 1
            }
          ]

          expect(VitaPartnerState.weighted_state_routing_ranges("RI")).to eq expected_array
        end
      end
    end
  end
end
