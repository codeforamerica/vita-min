require 'rails_helper'

RSpec.describe Efile::Id::Id39rCalculator do
  let(:intake) { create(:state_file_id_intake) }
  let(:instance) do
    described_class.new(
      value_access_tracker: Efile::ValueAccessTracker.new(include_source: true),
      lines: {},
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "#calculate_libe_b_6" do
    context "when TotalQlfdExpensesOrLimitAmt is least" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 200
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with qualified expenses amount' do
        instance.calculate
        expect(instance.lines[:ID39R_LINE_B_6].value).to eq 200
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
        expect(instance.lines[:ID39R_LINE_B_6].value).to eq 200
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
        expect(instance.lines[:ID39R_LINE_B_6].value).to eq 0
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
        expect(instance.lines[:ID39R_LINE_B_6].value).to eq 200
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
        expect(instance.lines[:ID39R_LINE_B_6].value).to eq 200
      end
    end
  end
end
