require 'rails_helper'

describe Efile::Nj::NjPropertyTaxEligibility do
  describe ".determine_eligibility" do
    [
      { filing_status: :single, income: 11_000, expected: :not_ineligible },
      { filing_status: :married_filing_separately, income: 11_000, expected: :not_ineligible },
      { filing_status: :married_filing_jointly, income: 21_000, expected: :not_ineligible },
      { filing_status: :single, income: 10_000, primary_over_65: true, expected: :ineligible_for_deduction },
      { filing_status: :single, income: 10_000, expected: :ineligible },
      { filing_status: :single, income: 9_999, primary_blind: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 19_999, spouse_blind: true, expected: :ineligible_for_deduction },
      { filing_status: :single, income: 9_999, primary_disabled: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 19_999, spouse_disabled: true, expected: :ineligible_for_deduction },
      { filing_status: :married_filing_jointly, income: 9_999, spouse_over_65: true, expected: :ineligible_for_deduction },
    ].each do |test_case|
      context "when filing #{test_case[:filing_status]} with income #{test_case[:income]}" do
        let(:intake) do
          traits = []
          traits << :married_filing_separately if test_case[:filing_status] == :married_filing_separately
          traits << :married_filing_jointly if test_case[:filing_status] == :married_filing_jointly
          traits << :primary_over_65 if test_case[:primary_over_65]
          traits << :primary_blind if test_case[:primary_blind]
          traits << :primary_disabled if test_case[:primary_disabled]
          traits << :spouse_blind if test_case[:spouse_blind]
          traits << :spouse_disabled if test_case[:spouse_disabled]
          traits << :mfj_spouse_over_65 if test_case[:spouse_over_65]

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
