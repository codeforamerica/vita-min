require 'rails_helper'

RSpec.describe Efile::Nj::NjRetirementIncomeHelper do

  describe "#calculate_maximum_exclusion for line 28a" do
    [
      { traits: [:single], total_income: 100_000, taxable_retirement_income: 40_000, expected: 75_000 },
      { traits: [:head_of_household], total_income: 100_000, taxable_retirement_income: 40_000, expected: 75_000 },
      { traits: [:qualifying_widow], total_income: 100_000, taxable_retirement_income: 40_000, expected: 75_000 },
      { traits: [:married_filing_jointly], total_income: 100_000, taxable_retirement_income: 40_000, expected: 100_000 },
      { traits: [:married_filing_separately], total_income: 100_000, taxable_retirement_income: 40_000, expected: 50_000 },

      { traits: [:single], total_income: 100_001, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:head_of_household], total_income: 100_001, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:qualifying_widow], total_income: 100_001, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:married_filing_jointly], total_income: 100_001, taxable_retirement_income: 40_000, expected: 20_000 },
      { traits: [:married_filing_separately], total_income: 100_001, taxable_retirement_income: 40_000, expected: 10_000 },

      { traits: [:single], total_income: 125_000, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:head_of_household], total_income: 125_000, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:qualifying_widow], total_income: 125_000, taxable_retirement_income: 40_000, expected: 15_000 },
      { traits: [:married_filing_jointly], total_income: 125_000, taxable_retirement_income: 40_000, expected: 20_000 },
      { traits: [:married_filing_separately], total_income: 125_000, taxable_retirement_income: 40_000, expected: 10_000 },

      { traits: [:single], total_income: 125_001, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:head_of_household], total_income: 125_001, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:qualifying_widow], total_income: 125_001, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:married_filing_jointly], total_income: 125_001, taxable_retirement_income: 40_000, expected: 10_000 },
      { traits: [:married_filing_separately], total_income: 125_001, taxable_retirement_income: 40_000, expected: 5_000 },

      { traits: [:single], total_income: 150_000, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:head_of_household], total_income: 150_000, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:qualifying_widow], total_income: 150_000, taxable_retirement_income: 40_000, expected: 7_500 },
      { traits: [:married_filing_jointly], total_income: 150_000, taxable_retirement_income: 40_000, expected: 10_000 },
      { traits: [:married_filing_separately], total_income: 150_000, taxable_retirement_income: 40_000, expected: 5_000 },

      { traits: [:single], total_income: 150_001, taxable_retirement_income: 40_000, expected: 0 },
      { traits: [:head_of_household], total_income: 150_001, taxable_retirement_income: 40_000, expected: 0 },
      { traits: [:qualifying_widow], total_income: 150_001, taxable_retirement_income: 40_000, expected: 0 },
      { traits: [:married_filing_jointly], total_income: 150_001, taxable_retirement_income: 40_000, expected: 0 },
      { traits: [:married_filing_separately], total_income: 150_001, taxable_retirement_income: 40_000, expected: 0 },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end
        it "returns #{test_case[:expected]}" do
          helper = Efile::Nj::NjRetirementIncomeHelper.new(intake)
          result = helper.calculate_maximum_exclusion(test_case[:total_income], test_case[:taxable_retirement_income])
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end

  describe "#line_28a_eligible?" do
    [
      { traits: [:single, :primary_over_62], line_27: 150_001, expected: false },
      { traits: [:single, :primary_under_62], line_27: 150_001, expected: false },
      { traits: [:single, :primary_blind], line_27: 150_001, expected: false },
      { traits: [:single, :primary_disabled], line_27: 150_001, expected: false },

      { traits: [:single, :primary_over_62], line_27: 150_000, expected: true },
      { traits: [:single, :primary_under_62], line_27: 150_000, expected: false },
      { traits: [:single, :primary_blind], line_27: 150_000, expected: true },
      { traits: [:single, :primary_disabled], line_27: 150_000, expected: true },

      { traits: [:married_filing_jointly, :primary_over_62, :mfj_spouse_over_62], line_27: 150_001, expected: false },
      { traits: [:married_filing_jointly, :primary_disabled, :spouse_disabled], line_27: 150_001, expected: false },
      { traits: [:married_filing_jointly, :primary_blind, :spouse_blind], line_27: 150_001, expected: false },

      { traits: [:married_filing_jointly, :primary_over_62, :mfj_spouse_over_62], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :primary_over_62, :mfj_spouse_under_62], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :primary_under_62, :mfj_spouse_over_62], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :primary_under_62, :mfj_spouse_under_62], line_27: 150_000, expected: false },

      { traits: [:married_filing_jointly, :primary_disabled, :spouse_disabled], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :primary_disabled], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :spouse_disabled], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly], line_27: 150_000, expected: false },

      { traits: [:married_filing_jointly, :primary_blind, :spouse_blind], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :primary_blind], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly, :spouse_blind], line_27: 150_000, expected: true },
      { traits: [:married_filing_jointly], line_27: 150_000, expected: false },
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
          allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_27).and_return(test_case[:line_27])
          instance.calculate
        end

        it "returns #{test_case[:expected]}" do
          result = helper.line_28a_eligible?(test_case[:line_27])
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end

  describe "#calculate_maximum_exclusion for line 28b" do
    [
      { traits: [:single], total_income: 100_000, expected: 75_000 },
      { traits: [:head_of_household], total_income: 100_000, expected: 75_000 },
      { traits: [:qualifying_widow], total_income: 100_000, expected: 75_000 },
      { traits: [:married_filing_jointly], total_income: 100_000, expected: 100_000 },
      { traits: [:married_filing_separately], total_income: 100_000, expected: 50_000 },

      { traits: [:single], total_income: 100_001, expected: 37_500 },
      { traits: [:head_of_household], total_income: 100_001, expected: 37_500 },
      { traits: [:qualifying_widow], total_income: 100_001, expected: 37_500 },
      { traits: [:married_filing_jointly], total_income: 100_001, expected: 50_001 },
      { traits: [:married_filing_separately], total_income: 100_001, expected: 25_000 },

      { traits: [:single], total_income: 125_000, expected: 46_875 },
      { traits: [:head_of_household], total_income: 125_000, expected: 46_875 },
      { traits: [:qualifying_widow], total_income: 125_000, expected: 46_875 },
      { traits: [:married_filing_jointly], total_income: 125_000, expected: 62_500 },
      { traits: [:married_filing_separately], total_income: 125_000, expected: 31_250 },

      { traits: [:single], total_income: 125_001, expected: 23_438 },
      { traits: [:head_of_household], total_income: 125_001, expected: 23_438 },
      { traits: [:qualifying_widow], total_income: 125_001, expected: 23_438 },
      { traits: [:married_filing_jointly], total_income: 125_001, expected: 31_250 },
      { traits: [:married_filing_separately], total_income: 125_001, expected: 15_625 },

      { traits: [:single], total_income: 150_000, expected: 28_125 },
      { traits: [:head_of_household], total_income: 150_000, expected: 28_125 },
      { traits: [:qualifying_widow], total_income: 150_000, expected: 28_125 },
      { traits: [:married_filing_jointly], total_income: 150_000, expected: 37_500 },
      { traits: [:married_filing_separately], total_income: 150_000, expected: 18_750 },

      { traits: [:single], total_income: 150_001, expected: 0 },
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
          result = helper.calculate_maximum_exclusion(test_case[:total_income], test_case[:total_income])
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end

  describe "#line_28b_eligible?" do
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
          result = helper.line_28b_eligible?(test_case[:line_15], test_case[:line_27], test_case[:line_28a])
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end

  describe "#total_eligible_nonretirement_income" do
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

  describe "#total_eligible_nonmilitary_1099r_income" do
    primary_ssn = 400000015
    spouse_ssn = 123456789
    let(:helper) { Efile::Nj::NjRetirementIncomeHelper.new(intake) }
    let!(:state_file_1099r_primary_1) { create :state_file1099_r, intake: intake, taxable_amount: 300.55, recipient_ssn: primary_ssn }
    let!(:state_file_1099r_primary_2) { create :state_file1099_r, intake: intake, taxable_amount: 400, recipient_ssn: primary_ssn }
    let!(:state_file_1099r_spouse_1) { create :state_file1099_r, intake: intake, taxable_amount: 500, recipient_ssn: spouse_ssn }
    let!(:state_file_1099r_spouse_2) { create :state_file1099_r, intake: intake, taxable_amount: 600, recipient_ssn: spouse_ssn }
    let!(:state_specific_followup_primary_1) { create :state_file_nj1099_r_followup, state_file1099_r: state_file_1099r_primary_1, income_source: income_source_primary_1 }
    let!(:state_specific_followup_primary_2) { create :state_file_nj1099_r_followup, state_file1099_r: state_file_1099r_primary_2, income_source: income_source_primary_2 }
    let!(:state_specific_followup_spouse_1) { create :state_file_nj1099_r_followup, state_file1099_r: state_file_1099r_spouse_1, income_source: income_source_spouse_1 }
    let!(:state_specific_followup_spouse_2) { create :state_file_nj1099_r_followup, state_file1099_r: state_file_1099r_spouse_2, income_source: income_source_spouse_2 }

    before do
      intake.reload
    end

    context 'when only primary is eligible' do
      let(:intake) { create(:state_file_nj_intake, :primary_disabled, :mfj_spouse_under_62) }
      let(:income_source_primary_1) { :none }
      let(:income_source_primary_2) { :military_pension }
      let(:income_source_spouse_1) { :none }
      let(:income_source_spouse_2) { :none }

      it 'sums taxable amount for only primary non-military 1099Rs, rounded' do
        expect(helper.total_eligible_nonmilitary_1099r_income).to eq(301)
      end
    end

    context 'when only spouse is eligible' do
      let(:intake) { create(:state_file_nj_intake, :primary_under_62, :mfj_spouse_over_62) }
      let(:income_source_primary_1) { :none }
      let(:income_source_primary_2) { :none }
      let(:income_source_spouse_1) { :military_pension }
      let(:income_source_spouse_2) { :none }

      it 'sums taxable amount for only spouse non-military 1099Rs' do
        expect(helper.total_eligible_nonmilitary_1099r_income).to eq(600)
      end
    end

    context 'when both primary and spouse are eligible' do
      let(:intake) { create(:state_file_nj_intake, :primary_disabled, :mfj_spouse_over_62) }
      let(:income_source_primary_1) { :military_pension }
      let(:income_source_primary_2) { :none }
      let(:income_source_spouse_1) { :none }
      let(:income_source_spouse_2) { :military_pension }

      it 'sums taxable amount for only all non-military 1099Rs' do
        expect(helper.total_eligible_nonmilitary_1099r_income).to eq(900)
      end
    end

    context 'when neither primary and spouse are eligible' do
      let(:intake) { create(:state_file_nj_intake, :primary_under_62, :mfj_spouse_under_62) }
      let(:income_source_primary_1) { :military_pension }
      let(:income_source_primary_2) { :none }
      let(:income_source_spouse_1) { :none }
      let(:income_source_spouse_2) { :military_pension }

      it 'returns 0' do
        expect(helper.total_eligible_nonmilitary_1099r_income).to eq(0)
      end
    end
  end
end
