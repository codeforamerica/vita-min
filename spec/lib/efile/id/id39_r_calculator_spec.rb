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
        expect(instance.lines[:ID39R_B_LINE_3].value).to eq(50)
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
    context "when sum of QualifiedCareExpensesPaidAmts is least" do
      before do
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(2)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(200)
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
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(2)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(2)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(1)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
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
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(1)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 200
      end

      it 'should expect to fill with primary earned income amount' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 200
      end
    end

    context "when there are no child or dependents cared for during the year" do
      before do
        allow(intake.direct_file_data).to receive(:dependent_cared_for_count).and_return(0)
        allow(intake.direct_file_data).to receive(:total_qualifying_dependent_care_expenses_no_limit).and_return(500)
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 200
      end

      it 'returns 0' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 0
      end
    end

    context "Ida HOH case" do
      let(:intake) { create(:state_file_id_intake, raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("id_ida_hoh")) }

      it 'returns 12,000' do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_6].value).to eq 12_000
      end
    end
  end

  describe "Section B Line 7: Taxable Social Security Amount" do
    context "when there is TaxableSocSecAmt" do
      before do
        intake.direct_file_data.fed_taxable_ssb = 123
      end
      it "rounds the amount" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_7].value).to eq(123)
      end
    end

    context "when there are no health insurance premiums" do
      before do
        intake.direct_file_data.fed_taxable_ssb = 0
      end

      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_7].value).to eq(0)
      end
    end
  end

  describe "Section B Line 18: Health Insurance Premium" do
    context "when there are health insurance premiums" do
      before do
        intake.update(has_health_insurance_premium: "yes", health_insurance_paid_amount: 12.55)
      end
      it "sums the interest from government bonds across all reports" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_18].value).to eq(13)
      end
    end

    context "when there are no health insurance premiums" do
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_18].value).to eq(0)
      end
    end
  end

  describe "Section B Line 24: Total Subtractions" do
    context "when there are sums" do
      before do
        allow(instance).to receive(:calculate_sec_b_line_3).and_return 2_000
        allow(instance).to receive(:calculate_sec_b_line_6).and_return 50
        allow(instance).to receive(:calculate_sec_b_line_7).and_return 100
        # line 8f is part of the calculation but it's always 0 for now
        allow(instance).to receive(:calculate_sec_b_line_18).and_return 1_000
      end

      it "sums the interest from government bonds across all reports" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_24].value).to eq(3150)
      end
    end

    context "when there are no subtractions" do
      before do
        allow(instance).to receive(:calculate_sec_b_line_3).and_return 0
        allow(instance).to receive(:calculate_sec_b_line_6).and_return 0
        allow(instance).to receive(:calculate_sec_b_line_7).and_return 0
        # line 8f is part of the calculation but it's always 0 for now
        allow(instance).to receive(:calculate_sec_b_line_18).and_return 0
      end
      it "returns 0" do
        instance.calculate
        expect(instance.lines[:ID39R_B_LINE_24].value).to eq(0)
      end
    end
  end
end
