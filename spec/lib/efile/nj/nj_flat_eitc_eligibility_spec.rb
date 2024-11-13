require 'rails_helper'

describe Efile::Nj::NjFlatEitcEligibility do
  describe ".possibly_eligible?" do
    [
      { traits: [], expected: false },
      { traits: [:married_filing_separately], expected: false },
      { traits: [:df_data_investment_income_12k], expected: false },
      { traits: [:df_data_minimal], expected: false },
      { traits: [:df_data_minimal, :married_filing_jointly], expected: false },
      { traits: [:df_data_childless_eitc], meets_age_requirements: false, expected: false },
      
      { traits: [:df_data_childless_eitc], expected: true },
      { traits: [:df_data_childless_eitc, :mfj_spouse_over_65], expected: true },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end

        it "returns #{test_case[:expected]}" do
          unless test_case[:meets_age_requirements].nil?
            allow(Efile::Nj::NjFlatEitcEligibility)
              .to receive(:meets_age_requirements?)
              .and_return(test_case[:meets_age_requirements])
          end
          
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

  describe ".meets_age_requirements?" do
    context "when mfj" do
      [
        { primary_age: 17, spouse_age: 17, expected: false },
        { primary_age: 18, spouse_age: 17, expected: true },
        { primary_age: 19, spouse_age: 17, expected: true },
        { primary_age: 17, spouse_age: 18, expected: true },
        { primary_age: 18, spouse_age: 18, expected: true },
        { primary_age: 19, spouse_age: 18, expected: true },
        { primary_age: 24, spouse_age: 24, expected: true },
        { primary_age: 25, spouse_age: 24, expected: false },
        { primary_age: 26, spouse_age: 24, expected: false },
        { primary_age: 24, spouse_age: 25, expected: false },
        { primary_age: 25, spouse_age: 25, expected: false },
        { primary_age: 26, spouse_age: 25, expected: false },
        { primary_age: 64, spouse_age: 64, expected: false },
        { primary_age: 65, spouse_age: 64, expected: false },
        { primary_age: 66, spouse_age: 64, expected: false },
        { primary_age: 64, spouse_age: 65, expected: false },
        { primary_age: 65, spouse_age: 65, expected: true },
        { primary_age: 66, spouse_age: 65, expected: true },
      ].each do |test_case|
        context "when #{test_case}" do
          let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
          it "returns #{test_case[:expected]}" do
            allow(intake)
              .to receive(:calculate_age)
              .with(intake.primary_birth_date, inclusive_of_jan_1: true)
              .and_return(test_case[:primary_age])
            allow(intake)
              .to receive(:calculate_age)
              .with(intake.spouse_birth_date, inclusive_of_jan_1: true)
              .and_return(test_case[:spouse_age])
            expect(Efile::Nj::NjFlatEitcEligibility.meets_age_requirements?(intake)).to eq(test_case[:expected])
          end
        end
      end
    end

    context "when not mfj" do
      [
        { primary_age: 17, expected: false },
        { primary_age: 18, expected: true },
        { primary_age: 19, expected: true },
        { primary_age: 24, expected: true },
        { primary_age: 25, expected: false },
        { primary_age: 26, expected: false },
        { primary_age: 64, expected: false },
        { primary_age: 65, expected: true },
        { primary_age: 66, expected: true },
      ].each do |test_case|
        context "when #{test_case}" do
          let(:intake) { create(:state_file_nj_intake) }
          it "returns #{test_case[:expected]}" do
            allow(intake)
              .to receive(:calculate_age)
              .and_return(test_case[:primary_age])
            expect(Efile::Nj::NjFlatEitcEligibility.meets_age_requirements?(intake)).to eq(test_case[:expected])
          end
        end
      end
    end
  end
end
