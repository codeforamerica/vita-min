require 'rails_helper'

describe Efile::Id::Id39RCalculator do
  let(:intake) { create(:state_file_id_intake) }
  let(:id40_calculator) do
    Efile::Id::Id40Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { id40_calculator.instance_variable_get(:@id39r) }

  describe "Section B Line 3: Interest on Government Bonds" do
    context "when there are interest reports with government bonds" do
      let(:intake) {
        create(:state_file_id_intake, :df_data_1099_int)
      }
      it "sums the interest from government bonds across all reports" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_3].value).to eq(2)
      end
    end

    context "when there are no interest reports" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_3].value).to eq(0)
      end
    end
  end

  describe "#calculate_line_sec_b_6" do
    context "when TotalQlfdExpensesOrLimitAmt is least" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 200
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with qualified expenses amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 200
      end
    end

    context "when ExcludedBenefitsAmt is least after subtracting from 12,000" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
        intake.direct_file_data.excluded_benefits_amount = 11_800
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with excluded benefits amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 200
      end
    end

    context "when ExcludedBenefitsAmt is greater than 12,000" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
        intake.direct_file_data.excluded_benefits_amount = 12_800
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with excluded benefits amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 0
      end
    end

    context "when PrimaryEarnedIncomeAmt is least" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 200
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with primary earned income amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 200
      end
    end

    context "when SpouseEarnedIncomeAmt is least" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 500
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 200
      end

      it 'should expect to fill with primary earned income amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 200
      end
    end
  end
end
