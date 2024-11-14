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
      { traits: [:df_data_childless_eitc], has_ssn_valid_for_employment: false, expected: false },
      { traits: [:df_data_childless_eitc], claimed_as_dependent: true, expected: false },
      
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

          unless test_case[:has_ssn_valid_for_employment].nil?
            allow(Efile::Nj::NjFlatEitcEligibility)
              .to receive(:has_ssn_valid_for_employment?)
              .and_return(test_case[:has_ssn_valid_for_employment])
          end

          unless test_case[:claimed_as_dependent].nil?
            allow(Efile::Nj::NjFlatEitcEligibility)
              .to receive(:claimed_as_dependent?)
              .and_return(test_case[:claimed_as_dependent])
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

    date_older_than_65 = Date.new(year_65+1, 1, 1) # 1/1/1960
    date_younger_than_65 = Date.new(year_65+1, 1, 2) # 1/2/1960

    date_older_than_25 = Date.new(year_25, 12, 31) # 12/31/1999
    date_younger_than_25 = Date.new(year_25+1, 1, 1) # 1/1/2000

    date_older_than_18 = Date.new(year_18, 12, 31) # 12/31/2006
    date_younger_than_18 = Date.new(year_18+1, 1, 1) # 1/1/2007

    context "when mfj" do
      [
        # 2024: Taxpayer is born on or before 1/1/1960. If MFJ, both taxpayers have to meet the requirement.
        { primary_birth_date: date_older_than_65, spouse_birth_date: date_older_than_65, expected: true },
        { primary_birth_date: date_younger_than_65, spouse_birth_date: date_older_than_65, expected: false },
        { primary_birth_date: date_older_than_65, spouse_birth_date: date_younger_than_65, expected: false },
        { primary_birth_date: date_younger_than_65, spouse_birth_date: date_younger_than_65, expected: false },

        # 2024: Taxpayer is born on or after 1/1/2000. If MFJ, both taxpayers have to meet the requirement.
        { primary_birth_date: date_younger_than_25, spouse_birth_date: date_younger_than_25, expected: true },
        { primary_birth_date: date_younger_than_25, spouse_birth_date: date_older_than_25, expected: false },
        { primary_birth_date: date_older_than_25, spouse_birth_date: date_younger_than_25, expected: false },
        { primary_birth_date: date_older_than_25, spouse_birth_date: date_older_than_25, expected: false },

        # 2024: taxpayer is born on or before 12/31/2006. If MFJ, only one taxpayer has to meet the requirement
        { primary_birth_date: date_younger_than_18, spouse_birth_date: date_younger_than_18, expected: false },
        { primary_birth_date: date_older_than_18, spouse_birth_date: date_younger_than_18, expected: true },
        { primary_birth_date: date_younger_than_18, spouse_birth_date: date_older_than_18, expected: true },
        { primary_birth_date: date_older_than_18, spouse_birth_date: date_older_than_18, expected: true },
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
        { primary_birth_date: date_older_than_65, expected: true },
        { primary_birth_date: date_younger_than_65, expected: false },

        # 2024: Taxpayer is born on or after 1/1/2000
        { primary_birth_date: date_younger_than_25, expected: true },
        { primary_birth_date: date_older_than_25, expected: false },

        # 2024: taxpayer is born on or before 12/31/2006
        { primary_birth_date: date_younger_than_18, expected: false },
        { primary_birth_date: date_older_than_18, expected: true },
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

    describe ".has_ssn_valid_for_employment?" do
      context "when mfj" do
        context "when spouse has itin" do
          let(:intake) { create(:state_file_nj_intake, :married_filing_jointly, :spouse_itin) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(false)
          end
        end

        context "when SSN is not valid for employment" do
          let(:intake) { create(:state_file_nj_intake, :df_data_ssn_not_valid_for_employment, :married_filing_jointly) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(false)
          end
        end

        context "returns true when SSN valid for employment" do
          let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
          it "returns true" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(true)
          end
        end
      end

      context "when not mfj" do
        context "when taxpayer has ITIN" do
          let(:intake) { create(:state_file_nj_intake, :primary_itin) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(false)
          end
        end

        context "when SSN is not valid for employment" do
          let(:intake) { create(:state_file_nj_intake, :df_data_ssn_not_valid_for_employment) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(false)
          end
        end

        context "returns true when SSN valid for employment" do
          let(:intake) { create(:state_file_nj_intake) }
          it "returns true" do
            expect(Efile::Nj::NjFlatEitcEligibility.has_ssn_valid_for_employment?(intake)).to eq(true)
          end
        end
      end
    end

    describe ".claimed_as_dependent?" do
      context "when mfj" do
        context "when spouse claimed as dependent" do
          let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
          it "returns true" do
            expect(Efile::Nj::NjFlatEitcEligibility.claimed_as_dependent?(intake)).to eq(true)
          end
        end

        context "when neither claimed as dependent" do
          let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.claimed_as_dependent?(intake)).to eq(false)
          end
        end
      end

      context "when not mfj" do
        context "when claimed as dependent" do
          let(:intake) { create(:state_file_nj_intake, :df_data_claimed_as_dependent) }
          it "returns true" do
            expect(Efile::Nj::NjFlatEitcEligibility.claimed_as_dependent?(intake)).to eq(true)
          end
        end

        context "when not claimed as dependent" do
          let(:intake) { create(:state_file_nj_intake) }
          it "returns false" do
            expect(Efile::Nj::NjFlatEitcEligibility.claimed_as_dependent?(intake)).to eq(false)
          end
        end
      end
    end
  end
end
