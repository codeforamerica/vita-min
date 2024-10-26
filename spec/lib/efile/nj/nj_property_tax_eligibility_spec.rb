require 'rails_helper'

describe Efile::Nj::NjPropertyTaxEligibility do
  describe ".determine_eligibility" do
    [
      { filing_status: :single, income: 11_000, expected: :not_ineligible },
      { filing_status: :married_filing_separately, income: 11_000, expected: :not_ineligible },
      { filing_status: :married_filing_jointly, income: 21_000, expected: :not_ineligible },
      { filing_status: :single, income: 10_000, over_65: true, expected: :ineligible_for_deduction },
      { filing_status: :single, income: 10_000, over_65: false, expected: :ineligible },
    ].each do |test_case|
      context "when filing #{test_case[:filing_status]} with income #{test_case[:income]}" do
        let(:intake) do
          if test_case[:filing_status] == :married_filing_separately
            if test_case[:over_65]
              create(:state_file_nj_intake, :married_filing_separately, :primary_over_65)
            else
              create(:state_file_nj_intake, :married_filing_separately)
            end
          elsif test_case[:filing_status] == :married_filing_jointly
            if test_case[:over_65]
              create(:state_file_nj_intake, :married_filing_jointly, :primary_over_65)
            else
              create(:state_file_nj_intake, :married_filing_jointly)
            end
          else
            if test_case[:over_65]
              create(:state_file_nj_intake, :primary_over_65)
            else
              create(:state_file_nj_intake)
            end
          end
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
