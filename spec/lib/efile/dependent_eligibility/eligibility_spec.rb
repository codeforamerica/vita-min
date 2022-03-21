require "rails_helper"

describe Efile::DependentEligibility::Eligibility do
  before do
    allow_any_instance_of(Efile::DependentEligibility::QualifyingChild).to receive(:qualifies?).and_return true
    allow_any_instance_of(Efile::DependentEligibility::ChildTaxCredit).to receive(:qualifies?).and_return true
    allow_any_instance_of(Efile::DependentEligibility::ChildTaxCredit).to receive(:benefit_amount).and_return 3600
    allow_any_instance_of(Efile::DependentEligibility::QualifyingChild).to receive(:age).and_return 5
    allow_any_instance_of(Efile::DependentEligibility::QualifyingRelative).to receive(:qualifies?).and_return false
    allow_any_instance_of(Efile::DependentEligibility::EipOne).to receive(:qualifies?).and_return false
    allow_any_instance_of(Efile::DependentEligibility::EipOne).to receive(:benefit_amount).and_return 0
    allow_any_instance_of(Efile::DependentEligibility::EipTwo).to receive(:benefit_amount).and_return 0
    allow_any_instance_of(Efile::DependentEligibility::EipTwo).to receive(:qualifies?).and_return false
    allow_any_instance_of(Efile::DependentEligibility::EipThree).to receive(:qualifies?).and_return true
    allow_any_instance_of(Efile::DependentEligibility::EipThree).to receive(:benefit_amount).and_return 1400
  end
  context ".test_results" do
    it "returns a hash with the eligibility results" do
      expect(
          Efile::DependentEligibility::Eligibility.new((create :dependent), TaxReturn.current_tax_year).test_results
      ).to eq ({
          qualifying_child: true,
          qualifying_relative: false,
          qualifying_ctc: true,
          qualifying_eip3: true,
          qualifying_eip2: false,
          qualifying_eip1: false,
      })
    end
  end

  context "#benefit_payments" do
    it "should return a hash with all of the payments broken down by program" do
      expect(
          Efile::DependentEligibility::Eligibility.new((create :dependent), TaxReturn.current_tax_year).benefit_amounts
      ).to eq ({
          ctc: 3600,
          eip3: 1400,
          eip2: 0,
          eip1: 0,
      })
    end
  end

  context "#total_benefit_amount" do
    it "should be the sum of each benefit's payments" do
      expect(
          Efile::DependentEligibility::Eligibility.new((create :dependent), TaxReturn.current_tax_year).total_benefit_amount
      ).to eq 5000
    end
  end
end