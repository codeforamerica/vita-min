require "rails_helper"

describe Efile::DependentEligibility::EipOne do
  context "when passing in an eligibility object" do
    let(:child_eligibility) { double }
    before do
      allow(child_eligibility).to receive(:qualifies?).and_return true
      allow(Efile::DependentEligibility::QualifyingChild).to receive(:new)

    end

    it "uses the passed in object instead of instantiating a new one" do
      described_class.new((create :dependent), TaxReturn.current_tax_year, child_eligibility: child_eligibility)
      expect(child_eligibility).to have_received(:qualifies?)
    end
  end

  context "when not passing in an eligibility object" do
    let(:dependent) { create :dependent }
    let(:child_eligibility) { double }
    before do
      allow(child_eligibility).to receive(:qualifies?).and_return true
    end

    it "instantiates a new eligibility object" do
      described_class.new(dependent, TaxReturn.current_tax_year)
      expect(child_eligibility).not_to have_received(:qualifies?)

    end
  end
end