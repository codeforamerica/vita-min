require "rails_helper"

RSpec.describe Hub::CoalitionForm do
  subject { described_class.new(coalition, params) }
  let(:coalition) { build(:coalition) }
  let(:params) { { states: states, name: name } }
  let(:name) { coalition.name }
  let(:states) { "" }

  describe "validations" do
    let(:name) { "" }

    it "requires name" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:name)
    end
  end

  describe "#save" do
    context "saving name" do
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

      context "form is not valid" do
        before do
          allow(subject).to receive(:valid?).and_return(false)
        end

        it "returns false and skips the rest" do
          expect {
            result = subject.save
            expect(result).to eq false
          }.not_to change { coalition }
        end
      end
    end

    context "updating states" do
      let(:states) { "OH,CA" }

      before do
        allow(UpdateStateRoutingTargetsService).to receive(:update)
      end

      it "creates the new state routing target" do
        subject.save
        expect(UpdateStateRoutingTargetsService).to have_received(:update).with(coalition, %w[OH CA])
      end
    end
  end
end
