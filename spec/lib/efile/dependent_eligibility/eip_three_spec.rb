require "rails_helper"

describe Efile::DependentEligibility::EipThree do
  context "when puerto_rico_filing? is true on the intake" do
    it "returns false, because PR dependents can not get eip3 money" do
      eligibility = described_class.new((create :qualifying_child, intake: create(:ctc_intake, home_location: "puerto_rico", client: create(:client, :with_return))), TaxReturn.current_tax_year)
      expect(eligibility.qualifies?).to eq false
    end
  end

  context "when passing in a qualifying child object" do
    let(:child_eligibility) { double }
    before do
      allow(child_eligibility).to receive(:qualifies?).and_return true
    end

    it "uses the passed in object instead of instantiating a new one" do
      described_class.new((create :dependent, intake: create(:ctc_intake)), TaxReturn.current_tax_year, child_eligibility: child_eligibility)
      expect(child_eligibility).to have_received(:qualifies?)
    end
  end

  context "when passing in a qualifying relative object" do
    let(:relative_eligibility) { double }
    before do
      allow(relative_eligibility).to receive(:qualifies?).and_return true
    end

    it "uses the passed in object instead of instantiating a new one" do
      described_class.new((create :dependent, intake: create(:ctc_intake, client: create(:client, :with_return))), TaxReturn.current_tax_year, relative_eligibility: relative_eligibility)
      expect(relative_eligibility).to have_received(:qualifies?)
    end
  end
end