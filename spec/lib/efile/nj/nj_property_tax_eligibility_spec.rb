require 'rails_helper'

describe Efile::Nj::NjPropertyTaxEligibility do
  describe ".determine_eligibility" do
    [
      { filing_status: :single, income: 10_001, expected: :not_ineligible },
      { filing_status: :married_filing_jointly, income: 20_001, expected: :not_ineligible },
      { filing_status: :married_filing_separately, income: 10_001, expected: :not_ineligible },
      { filing_status: :head_of_household, income: 20_001, expected: :not_ineligible },
      { filing_status: :qualifying_widow, income: 20_001, expected: :not_ineligible },

      { filing_status: :single, income: 10_000, primary_over_65: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 20_000, primary_blind: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_separately, income: 10_000, primary_disabled: true, expected: :ineligible_for_deduction },
      { filing_status: :head_of_household, income: 20_000, primary_over_65: true, expected: :ineligible_for_deduction },
      { filing_status: :qualifying_widow, income: 20_000, primary_blind: true, expected: :ineligible_for_deduction },

      { filing_status: :married_filing_jointly, income: 19_999, spouse_over_65: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 19_999, spouse_blind: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 19_999, spouse_disabled: true, expected: :ineligible_for_deduction },

      { filing_status: :single, income: 10_000, expected: :ineligible },
      { filing_status: :married_filing_jointly, income: 20_000, expected: :ineligible },
      { filing_status: :married_filing_separately, income: 10_000, expected: :ineligible },
      { filing_status: :head_of_household, income: 20_000, expected: :ineligible },
      { filing_status: :qualifying_widow, income: 20_000, expected: :ineligible },
      { filing_status: :single, income: 9_999, expected: :ineligible },
      { filing_status: :married_filing_jointly, income: 19_999, expected: :ineligible },
      { filing_status: :married_filing_separately, income: 9_999, expected: :ineligible },
      { filing_status: :head_of_household, income: 19_999, expected: :ineligible },
      { filing_status: :qualifying_widow, income: 19_999, expected: :ineligible },
    ].each do |test_case|
      context "when filing #{test_case}" do
        let(:intake) do
          traits = []
          traits << test_case[:filing_status] if test_case[:filing_status] != :single
          traits << :married_filing_jointly if test_case[:filing_status] == :married_filing_jointly
          traits << :primary_over_65 if test_case[:primary_over_65]
          traits << :primary_blind if test_case[:primary_blind]
          traits << :primary_disabled if test_case[:primary_disabled]
          traits << :mfj_spouse_over_65 if test_case[:spouse_over_65]
          traits << :spouse_blind if test_case[:spouse_blind]
          traits << :spouse_disabled if test_case[:spouse_disabled]

          create(:state_file_nj_intake, *traits)
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
