require 'rails_helper'

RSpec.describe Efile::Nj::NjRetirementIncomeHelper do
  describe ".calculate_maximum_exclusion" do
    [
      { total_income: 100_000, expected: 75_000 },
      { traits: [:head_of_household], total_income: 100_000, expected: 75_000 },
      { traits: [:qualifying_widow], total_income: 100_000, expected: 75_000 },
      { traits: [:married_filing_jointly], total_income: 100_000, expected: 100_000 },
      { traits: [:married_filing_separately], total_income: 100_000, expected: 50_000 },

      { total_income: 100_001, expected: 37_500 },
      { traits: [:head_of_household], total_income: 100_001, expected: 37_500 },
      { traits: [:qualifying_widow], total_income: 100_001, expected: 37_500 },
      { traits: [:married_filing_jointly], total_income: 100_001, expected: 50_001 },
      { traits: [:married_filing_separately], total_income: 100_001, expected: 25_000 },

      { total_income: 125_000, expected: 46_875 },
      { traits: [:head_of_household], total_income: 125_000, expected: 46_875 },
      { traits: [:qualifying_widow], total_income: 125_000, expected: 46_875 },
      { traits: [:married_filing_jointly], total_income: 125_000, expected: 62_500 },
      { traits: [:married_filing_separately], total_income: 125_000, expected: 31_250 },

      { total_income: 125_001, expected: 23_438 },
      { traits: [:head_of_household], total_income: 125_001, expected: 23_438 },
      { traits: [:qualifying_widow], total_income: 125_001, expected: 23_438 },
      { traits: [:married_filing_jointly], total_income: 125_001, expected: 31_250 },
      { traits: [:married_filing_separately], total_income: 125_001, expected: 15_625 },

      { total_income: 150_000, expected: 28_125 },
      { traits: [:head_of_household], total_income: 150_000, expected: 28_125 },
      { traits: [:qualifying_widow], total_income: 150_000, expected: 28_125 },
      { traits: [:married_filing_jointly], total_income: 150_000, expected: 37_500 },
      { traits: [:married_filing_separately], total_income: 150_000, expected: 18_750 },

      { total_income: 150_001, expected: 0 },
      { traits: [:head_of_household], total_income: 150_001, expected: 0 },
      { traits: [:qualifying_widow], total_income: 150_001, expected: 0 },
      { traits: [:married_filing_jointly], total_income: 150_001, expected: 0 },
      { traits: [:married_filing_separately], total_income: 150_001, expected: 0 },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end
        it "returns #{test_case[:expected]}" do
          helper = Efile::Nj::NjRetirementIncomeHelper.new(intake)
          result = helper.calculate_maximum_exclusion(test_case[:total_income])
          expect(result).to eq(test_case[:expected])
        end
      end
    end

    describe ".retirement_exclusion_eligible?" do
      [
        { traits: [:mfj_spouse_over_62], line_15: 3_000, line_27: 150_000, line_28a: 37_500, expected: true },
        { traits: [:primary_over_62], line_15: 3_000, line_27: 150_000, line_28a: 28_125, expected: true },
        { traits: [:primary_under_62], line_15: 3_000, line_27: 150_000, line_28a: 28_125, expected: false },
        { traits: [:primary_over_62], line_15: 3_000, line_27: 150_001, line_28a: 0, expected: false },
        { traits: [:primary_over_62], line_15: 3_001, line_27: 99_999, line_28a: 0, expected: false },
        { traits: [:primary_over_62], line_15: 3_000, line_27: 150_000, line_28a: 100_000, expected: false },
      ].each do |test_case|
        context "when filing with #{test_case}" do
          let(:intake) do
            create(:state_file_nj_intake, *test_case[:traits])
          end
          let(:instance) do
            Efile::Nj::Nj1040Calculator.new(
              year: MultiTenantService.statefile.current_tax_year,
              intake: intake
            )
          end
          let(:helper) do
            Efile::Nj::NjRetirementIncomeHelper.new(intake)
          end
          before do
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return(test_case[:line_15])
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_27).and_return(test_case[:line_27])
            allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_28a).and_return(test_case[:line_28a])
            instance.calculate
          end

          it "returns #{test_case[:expected]}" do
            result = helper.retirement_exclusion_eligible?(test_case[:line_15], test_case[:line_27], test_case[:line_28a])
            expect(result).to eq(test_case[:expected])
          end
        end
      end
    end

    describe ".total_eligible_nonretirement_income" do
      let(:helper) do
        Efile::Nj::NjRetirementIncomeHelper.new(intake)
      end
      before do
        primary_ssn = 400000015
        spouse_ssn = 123456789
        first_w2 = intake.state_file_w2s.first 
        first_w2.update_attribute(:employee_ssn, primary_ssn)
        first_w2.update_attribute(:state_wages_amount, 1_000)
        first_1099_int = intake.direct_file_json_data.interest_reports.first
        first_1099_int.recipient_tin = primary_ssn.to_s
        first_1099_int.amount_1099 = 2_000
        first_1099_int.amount_no_1099 = nil
        second_1099_int = intake.direct_file_json_data.interest_reports.second
        second_1099_int.recipient_tin = spouse_ssn.to_s
        second_1099_int.amount_1099 = nil
        second_1099_int.amount_no_1099 = 4_000
      end
      context "when primary and spouse are both over 62" do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep, :primary_over_62, :mfj_spouse_over_62) }

        it 'sums both spouse and primary wages in total eligible income' do
          expect(helper.total_eligible_nonretirement_income).to eq(7_000)
        end
      end

      context "when only primary is over 62" do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep, :primary_over_62) }

        it 'sums only primary wages in total eligible income' do
          expect(helper.total_eligible_nonretirement_income).to eq(3_000)
        end
      end

      context "when only spouse is over 62" do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep, :mfj_spouse_over_62) }

        it 'sums only spouse wages in total eligible income' do
          expect(helper.total_eligible_nonretirement_income).to eq(4_000)
        end
      end

      context "when neither primary or spouse is over 62" do
        let(:intake) { create(:state_file_nj_intake, :df_data_one_dep, :primary_under_62) }

        it 'sums neither filers wages in total eligible income' do
          expect(helper.total_eligible_nonretirement_income).to eq(0)
        end
      end
    end
  end
end
