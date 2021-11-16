require 'rails_helper'

describe WeightedRoutingService do
  describe "#weighted_routing_ranges" do
    context "when there are vita partners for state" do
      subject { described_class.new(StateRoutingTarget.where(state: "RI")) }

      context "when all the vita partners have a value of 0 for routing fraction" do
        let!(:first_vps) { create :state_routing_target, routing_fraction: 0.0, state: "RI" }
        let!(:second_vps) { create :state_routing_target, routing_fraction: 0.0, state: "RI" }
        let!(:third_vps) { create :state_routing_target, routing_fraction: 0.0, state: "RI" }
        it "returns an empty array" do
          expect(subject.weighted_routing_ranges).to eq []
        end
      end

      context "when there are multiple vita partners with different routing fractions" do
        let!(:zeroth_vps) { create :state_routing_target, routing_fraction: 0.0, state: "RI" }
        let!(:first_vps) { create :state_routing_target, routing_fraction: 0.2, state: "RI" }
        let!(:second_vps) { create :state_routing_target, routing_fraction: 0.9, state: "RI" }
        let!(:third_vps) { create :state_routing_target, routing_fraction: 0.0, state: "RI" }
        let!(:fourth_vps) { create :state_routing_target, routing_fraction: 0.3, state: "RI" }
        let!(:out_of_state_vps) { create :state_routing_target, routing_fraction: 0.9, state: "MD" }

        it "returns an array with vita partner ids and routing fraction range for all vita partners in that state" do
          expected_array = [
            {
                id: first_vps.vita_partner_id,
                low: 0.0,
                high: 0.1429
            },
            {
                id: second_vps.vita_partner_id,
                low: 0.1429,
                high: 0.7858
            },
            {
                id: fourth_vps.vita_partner_id,
                low: 0.7858,
                high: 1.0
            }
          ]

          expect(subject.weighted_routing_ranges).to eq expected_array
        end
      end
    end
  end
end