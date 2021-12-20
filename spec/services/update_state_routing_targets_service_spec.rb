require "rails_helper"

RSpec.describe UpdateStateRoutingTargetsService do
  describe ".update" do
    let(:params) { { states: states, name: name } }
    let(:name) { coalition.name }
    let(:states) { "" }

    context "adding states" do
      let(:coalition) { create(:coalition, state_routing_targets: [build(:state_routing_target, state_abbreviation: "OH")]) }
      let(:states) { %w[OH CA] }

      it "creates the new state routing target" do
        described_class.update(coalition, states)
        coalition.save
        expect(coalition.reload.state_routing_targets.pluck(:state_abbreviation)).to match_array %w[OH CA]
      end
    end

    context "removing states" do
      let(:coalition) { create(:coalition) }
      let(:states) { %w[UT CA] }

      before do
        create(:state_routing_target, state_abbreviation: "OH", target: coalition)
      end

      it "destroys the old state routing target" do
        described_class.update(coalition, states)
        coalition.save
        expect(coalition.reload.state_routing_targets.pluck(:state_abbreviation)).to match_array %w[UT CA]
        expect(StateRoutingTarget.where(state_abbreviation: "OH").count).to eq 0
      end
    end
  end
end
