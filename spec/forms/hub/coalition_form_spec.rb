require "rails_helper"

RSpec.describe Hub::CoalitionForm do
  describe "#save" do
    subject { described_class.new(coalition, params) }
    let(:params) { { states: states, name: name } }
    let(:name) { coalition.name }
    let(:states) { "" }

    context "saving name" do
      let(:coalition) { Coalition.new }
      let(:name) { "A New Coalition" }

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

    context "updating states" do
      let(:states) { "OH,CA" }

      it "creates the new state routing target" do
        subject.save
        expect(UpdateStateRoutingTargetsService).to have_received(:update).with(coalition, %w[OH CA])
      end
    end
  end
end
