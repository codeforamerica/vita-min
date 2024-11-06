require 'rails_helper'

describe Efile::Nj::NjPropertyTaxEligibility do
  describe ".determine_eligibility" do
    [
      { income: 10_001, expected: :possibly_eligible_for_deduction_or_credit },
      { traits: [:married_filing_jointly], income: 20_001, expected: :possibly_eligible_for_deduction_or_credit },
      { traits: [:married_filing_separately], income: 10_001, expected: :possibly_eligible_for_deduction_or_credit },
      { traits: [:head_of_household], income: 20_001, expected: :possibly_eligible_for_deduction_or_credit },
      { traits: [:qualifying_widow], income: 20_001, expected: :possibly_eligible_for_deduction_or_credit },

      { traits: [:primary_over_65], income: 10_000, expected: :possibly_eligible_for_credit },
      { traits: [:married_filing_jointly, :primary_blind], income: 20_000, expected: :possibly_eligible_for_credit },
      { traits: [:married_filing_separately, :primary_disabled], income: 10_000, expected: :possibly_eligible_for_credit },
      { traits: [:head_of_household, :primary_over_65], income: 20_000, expected: :possibly_eligible_for_credit },
      { traits: [:qualifying_widow, :primary_blind], income: 20_000, expected: :possibly_eligible_for_credit },

      { traits: [:married_filing_jointly, :mfj_spouse_over_65], income: 19_999, expected: :possibly_eligible_for_credit },
      { traits: [:married_filing_jointly, :spouse_blind], income: 19_999, expected: :possibly_eligible_for_credit },
      { traits: [:married_filing_jointly, :spouse_disabled], income: 19_999, expected: :possibly_eligible_for_credit },

      { income: 10_000, expected: :ineligible },
      { traits: [:married_filing_jointly], income: 20_000, expected: :ineligible },
      { traits: [:married_filing_separately], income: 10_000, expected: :ineligible },
      { traits: [:head_of_household], income: 20_000, expected: :ineligible },
      { traits: [:qualifying_widow], income: 20_000, expected: :ineligible },

      { income: 9_999, expected: :ineligible },
      { traits: [:married_filing_jointly], income: 19_999, expected: :ineligible },
      { traits: [:married_filing_separately], income: 9_999, expected: :ineligible },
      { traits: [:head_of_household], income: 19_999, expected: :ineligible },
      { traits: [:qualifying_widow], income: 19_999, expected: :ineligible },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end

        it "returns #{test_case[:expected]}" do
          allow(Efile::Nj::NjStateWages).to receive(:calculate_state_wages).and_return(test_case[:income])

          result = Efile::Nj::NjPropertyTaxEligibility.determine_eligibility(intake)
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end
end
