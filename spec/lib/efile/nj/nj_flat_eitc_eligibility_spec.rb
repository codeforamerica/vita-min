require 'rails_helper'

describe Efile::Nj::NjFlatEitcEligibility do
  describe ".possibly_eligible?" do
    [
      { traits: [], expected: false },
      { traits: [:married_filing_separately], expected: false },
      { traits: [:df_data_investment_income_12k], expected: false },
      { traits: [:df_data_minimal], expected: false },
      { traits: [:df_data_minimal, :married_filing_jointly], expected: false },
      
      { traits: [:df_data_childless_eitc], expected: true },
      { traits: [:df_data_childless_eitc, :married_filing_jointly], expected: true },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end

        it "returns #{test_case[:expected]}" do
          result = Efile::Nj::NjFlatEitcEligibility.possibly_eligible?(intake)
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end

  describe ".investment_income_over_limit?" do
    context "when above limit" do
      let(:intake) { create(:state_file_nj_intake, :df_data_investment_income_12k) }
      it "returns true" do
        expect(Efile::Nj::NjFlatEitcEligibility.investment_income_over_limit?(intake)).to eq(true)
      end
    end

    context "when under limit" do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
      it "returns false" do
        expect(Efile::Nj::NjFlatEitcEligibility.investment_income_over_limit?(intake)).to eq(false)
      end
    end
  end
end
