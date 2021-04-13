require "rails_helper"

describe TriageLookbackForm do
  subject { described_class.new(params) }

  let(:had_income_decrease) { "no" }
  let(:had_unemployment) { "no" }
  let(:had_marketplace_insurance) { "no" }
  let(:none) { "no" }
  let(:params) do
    {
        had_income_decrease: had_income_decrease,
        had_unemployment: had_unemployment,
        had_marketplace_insurance: had_marketplace_insurance,
        none: none
    }
  end

  context "an instance" do
    it 'responds to #had_income_decrease' do
      expect(subject).to respond_to :had_income_decrease
    end

    it "responds to #had_unemployment" do
      expect(subject).to respond_to :had_unemployment
    end

    it "responds to #had_marketplace_insurance" do
      expect(subject).to respond_to :had_marketplace_insurance
    end

    it "responds to #none" do
      expect(subject).to respond_to :none
    end
  end

  context "#valid?" do
    context "when all selections are no" do
      it "returns false and adds an error to the form" do
        expect(subject.valid?).to eq false
        expect(subject.errors).to include :at_least_one_selection
      end
    end

    context "when at least one selection is yes" do
      let(:none) { "yes" }
      it "returns true" do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe "#has_complex_situation?" do
    context "when all selections are no" do
      it "is false" do
        expect(subject.has_complex_situation?).to eq false
      end
    end

    context "when one of the complex selections is yes" do
      let(:had_income_decrease) { "yes" }
      it "is true" do
        expect(subject.has_complex_situation?).to eq true
      end
    end
  end
end