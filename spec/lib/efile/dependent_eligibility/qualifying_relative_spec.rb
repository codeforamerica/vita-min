require "rails_helper"

describe Efile::DependentEligibility::QualifyingRelative do
  subject { described_class.new(dependent, TaxReturn.current_tax_year)}

  context 'with a totally qualifying relative' do
    let(:dependent) { create :qualifying_relative }
    let(:test_result) do
      {
          is_supported_test: true,
          relationship_test: true,
          tin_test: true,
          residence_test: true,
          financial_support_test: true,
          residence_test: true,
          claimable_test: true
      }
    end

    it "returns true for #qualifies?" do
      expect(subject.qualifies?).to eq true
    end

    it "has the raw test_results with all true values" do
      expect(subject.test_results).to eq test_result
    end

    it "has an empty array for disqualifiers" do
      expect(subject.disqualifiers).to eq []
    end
  end
end