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
      { traits: [:df_data_childless_eitc], is_under_income_total_limit: false, expected: false },
      
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

          unless test_case[:is_under_income_total_limit].nil?
            allow(Efile::Nj::NjFlatEitcEligibility)
              .to receive(:is_under_income_total_limit?)
              .and_return(test_case[:is_under_income_total_limit])
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
    current_tax_year = MultiTenantService.statefile.current_tax_year
    year_65 = current_tax_year - 65 # for 2024: 1959
    year_25 = current_tax_year - 25 # for 2024: 1999
    year_18 = current_tax_year - 18 # for 2024: 2006

    context "when mfj" do
      [
        # 2024: Taxpayer is born on or before 1/1/1960. If MFJ, both taxpayers have to meet the requirement.
        { primary_birth_date: Date.new(year_65+1, 1, 1), spouse_birth_date: Date.new(year_65+1, 1, 1), expected: true },
        { primary_birth_date: Date.new(year_65+1, 1, 2), spouse_birth_date: Date.new(year_65+1, 1, 1), expected: false },
        { primary_birth_date: Date.new(year_65+1, 1, 1), spouse_birth_date: Date.new(year_65+1, 1, 2), expected: false },
        { primary_birth_date: Date.new(year_65+1, 1, 2), spouse_birth_date: Date.new(year_65+1, 1, 2), expected: false },

        # 2024: Taxpayer is born on or after 1/1/2000. If MFJ, both taxpayers have to meet the requirement.
        { primary_birth_date: Date.new(year_25+1, 1, 1), spouse_birth_date: Date.new(year_25+1, 1, 1), expected: true },
        { primary_birth_date: Date.new(year_25+1, 1, 1), spouse_birth_date: Date.new(year_25, 12, 31), expected: false },
        { primary_birth_date: Date.new(year_25, 12, 31), spouse_birth_date: Date.new(year_25+1, 1, 1), expected: false },
        { primary_birth_date: Date.new(year_25, 12, 31), spouse_birth_date: Date.new(year_25, 12, 31), expected: false },

        # 2024: taxpayer is born on or before 12/31/2006. If MFJ, only one taxpayer has to meet the requirement
        { primary_birth_date: Date.new(year_18+1, 1, 1), spouse_birth_date: Date.new(year_18+1, 1, 1), expected: false },
        { primary_birth_date: Date.new(year_18, 12, 31), spouse_birth_date: Date.new(year_18+1, 1, 1), expected: true },
        { primary_birth_date: Date.new(year_18+1, 1, 1), spouse_birth_date: Date.new(year_18, 12, 31), expected: true },
        { primary_birth_date: Date.new(year_18, 12, 31), spouse_birth_date: Date.new(year_18, 12, 31), expected: true },
      ].each do |test_case|
        context "when #{test_case}" do
          let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
          it "returns #{test_case[:expected]}" do
            allow(intake).to receive(:primary_birth_date).and_return(test_case[:primary_birth_date])
            allow(intake).to receive(:spouse_birth_date).and_return(test_case[:spouse_birth_date])

            expect(Efile::Nj::NjFlatEitcEligibility.meets_age_requirements?(intake)).to eq(test_case[:expected])
          end
        end
      end
    end

    context "when not mfj" do
      [
         # 2024: Taxpayer is born on or before 1/1/1960
        { primary_birth_date: Date.new(year_65+1, 1, 1), expected: true },
        { primary_birth_date: Date.new(year_65+1, 1, 2), expected: false },

        # 2024: Taxpayer is born on or after 1/1/2000
        { primary_birth_date: Date.new(year_25+1, 1, 1), expected: true },
        { primary_birth_date: Date.new(year_25, 12, 31), expected: false },

        # 2024: taxpayer is born on or before 12/31/2006
        { primary_birth_date: Date.new(year_18+1, 1, 1), expected: false },
        { primary_birth_date: Date.new(year_18, 12, 31), expected: true },
      ].each do |test_case|
        context "when #{test_case}" do
          let(:intake) { create(:state_file_nj_intake) }
          it "returns #{test_case[:expected]}" do
            allow(intake).to receive(:primary_birth_date).and_return(test_case[:primary_birth_date])
            expect(Efile::Nj::NjFlatEitcEligibility.meets_age_requirements?(intake)).to eq(test_case[:expected])
          end
        end
      end
    end
  end

  describe ".is_under_income_total_limit?" do
    context "when mfj" do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "returns false when at limit" do
        allow(intake.direct_file_data).to receive(:fed_income_total).and_return(24_210)
        expect(Efile::Nj::NjFlatEitcEligibility.is_under_income_total_limit?(intake)).to eq(false)
      end

      it "returns true when below limit" do
        allow(intake.direct_file_data).to receive(:fed_income_total).and_return(24_209)
        expect(Efile::Nj::NjFlatEitcEligibility.is_under_income_total_limit?(intake)).to eq(true)
      end
    end

    context "when not mfj" do
      let(:intake) { create(:state_file_nj_intake) }
      it "returns false when at limit" do
        allow(intake.direct_file_data).to receive(:fed_income_total).and_return(17_640)
        expect(Efile::Nj::NjFlatEitcEligibility.is_under_income_total_limit?(intake)).to eq(false)
      end

      it "returns true when below limit" do
        allow(intake.direct_file_data).to receive(:fed_income_total).and_return(17_639)
        expect(Efile::Nj::NjFlatEitcEligibility.is_under_income_total_limit?(intake)).to eq(true)
      end
    end
  end
end
