require "rails_helper"

describe Efile::DependentEligibility::QualifyingRelative do
  subject { described_class.new(dependent, TaxReturn.current_tax_year) }

  context 'with a totally qualifying relative' do
    let(:dependent) { create :qualifying_relative, intake: create(:ctc_intake) }
    let(:expected_test_result) do
      {   wants_to_claim_test: true,
          birth_test: true,
          married_filing_joint_test: true,
          is_supported_test: true,
          relationship_test: true,
          tin_test: true,
          residence_test: true,
          financial_support_test: true,
          claimable_test: true,
          home_location_test: true
      }
    end

    it "returns true for #qualifies?" do
      expect(subject.qualifies?).to eq true
    end

    it "has the raw test_results with all true values" do
      expect(subject.test_results).to eq expected_test_result
    end

    it "has an empty array for disqualifiers" do
      expect(subject.disqualifiers).to eq []
    end

    context "but the home location on the intake is puerto rico" do
      let(:dependent) { create(:qualifying_relative, intake: create(:ctc_intake, home_location: "puerto_rico")) }

      before do
        expected_test_result[:home_location_test] = false
      end

      it "returns false for #qualifies?" do
        expect(subject.qualifies?).to eq false
      end

      it "has the raw test_results with all true values but the home_location_test" do
        expect(subject.test_results).to eq expected_test_result
      end

      it "has home_location_test in the array for disqualifiers" do
        expect(subject.disqualifiers).to eq [:home_location_test]
      end
    end
  end
end