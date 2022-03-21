require "rails_helper"

describe Efile::DependentEligibility::EipThree do
  context "when passing in a qualifying child object" do
    let(:child_eligibility) { double }
    before do
      allow(child_eligibility).to receive(:qualifies?).and_return true
    end

    it "uses the passed in object instead of instantiating a new one" do
      described_class.new((create :dependent), TaxReturn.current_tax_year, child_eligibility: child_eligibility)
      expect(child_eligibility).to have_received(:qualifies?)
    end

  end

  context "when passing in a qualifying relative object" do
    let(:relative_eligibility) { double }
    before do
      allow(relative_eligibility).to receive(:qualifies?).and_return true
    end

    it "uses the passed in object instead of instantiating a new one" do
      described_class.new((create :dependent), TaxReturn.current_tax_year, relative_eligibility: relative_eligibility)
      expect(relative_eligibility).to have_received(:qualifies?)
    end

  end
end