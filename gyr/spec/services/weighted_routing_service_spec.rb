require 'rails_helper'

describe WeightedRoutingService do
  describe "#weighted_routing_ranges" do
    context "when initialized with a collection of routing fractions" do
      subject { described_class.new([first_srf, second_srf, third_srf, fourth_srf]) }

      let(:first_srt) { create(:state_routing_target, target: create(:organization), state_abbreviation: "RI") }
      let(:second_srt) { create(:state_routing_target, target: create(:organization), state_abbreviation: "RI") }
      let(:third_srt) { create(:state_routing_target, target: create(:organization), state_abbreviation: "RI") }
      let(:fourth_srt) { create(:state_routing_target, target: create(:organization), state_abbreviation: "RI") }

      let(:first_srf) { create(:state_routing_fraction, state_routing_target: first_srt, routing_fraction: fraction_1, vita_partner: first_srt.target) }
      let(:second_srf) { create(:state_routing_fraction, state_routing_target: second_srt, routing_fraction: fraction_2, vita_partner: second_srt.target) }
      let(:third_srf) { create(:state_routing_fraction, state_routing_target: third_srt, routing_fraction: fraction_3, vita_partner: third_srt.target) }
      let(:fourth_srf) { create(:state_routing_fraction, state_routing_target: third_srt, routing_fraction: fraction_4, vita_partner: third_srt.target) }

      context "when all the vita partners have a value of 0 for routing fraction" do
        let(:fraction_1) { 0.0 }
        let(:fraction_2) { 0.0 }
        let(:fraction_3) { 0.0 }
        let(:fraction_4) { 0.0 }

        it "returns an empty array" do
          expect(subject.weighted_routing_ranges).to eq []
        end
      end

      context "when vita partners have different routing fractions" do
        let(:fraction_1) { 0.2 }
        let(:fraction_2) { 0.3 }
        let(:fraction_3) { 0.1 }
        let(:fraction_4) { 0.0 }

        it "returns an array with vita partner ids and routing fraction range for all vita partners in that state" do
          expected_array = [
            {
                id: first_srf.vita_partner_id,
                low: 0.0,
                high: 0.3333
            },
            {
                id: second_srf.vita_partner_id,
                low: 0.3333,
                high: 0.8332999999999999
            },
            {
                id: third_srf.vita_partner_id,
                low: 0.8332999999999999,
                high: 1.0
            }
          ]

          expect(subject.weighted_routing_ranges).to eq expected_array
        end
      end
    end

    context "when initialized with an empty collection" do
      subject { described_class.new([])}

      it "returns an empty array" do
        expect(subject.weighted_routing_ranges).to eq []
      end
    end
  end
end