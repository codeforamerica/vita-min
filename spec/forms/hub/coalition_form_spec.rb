require "rails_helper"

RSpec.describe Hub::CoalitionForm do
  describe "#save" do
    subject { described_class.new(params) }

    context "saving name" do
      let(:coalition) { Coalition.new(name: "A New Coalition") }
      let(:params) { { states: "", coalition: coalition } }

      it "saves the coalition with the new name" do
        subject.save
        expect(coalition.name).to eq "A New Coalition"
      end

      context "when another coalition has the name already" do
        before do
          create(:coalition, name: "A New Coalition")
        end

        it "adds an error" do
          subject.save
          expect(coalition.errors[:name]).to eq ["has already been taken"]
        end
      end
    end

    context "adding states" do
      let(:coalition) { create(:coalition, state_routing_targets: [build(:state_routing_target, state_abbreviation: "OH")]) }
      let(:params) { { states: "OH,CA", coalition: coalition } }

      it "creates the new state routing target" do
        subject.save
        expect(coalition.reload.state_routing_targets.pluck(:state_abbreviation)).to match_array ["OH", "CA"]
      end
    end

    context "removing states" do
      let(:coalition) { create(:coalition) }
      let(:params) { { states: "UT,CA", coalition: coalition } }

      before do
        create(:state_routing_target, state_abbreviation: "OH", target: coalition)
      end

      it "destroys the old state routing target" do
        subject.save
        expect(coalition.reload.state_routing_targets.pluck(:state_abbreviation)).to match_array ["UT", "CA"]
        expect(StateRoutingTarget.where(state_abbreviation: "OH").count).to eq 0
      end
    end
  end
end
