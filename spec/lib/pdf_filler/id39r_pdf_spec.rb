require 'rails_helper'

RSpec.describe PdfFiller::Id39rPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_id_intake) }
  let(:submission) { create(:efile_submission, tax_return: nil, data_source: intake) }
  let(:pdf) { described_class.new(submission) }
  let(:file_path) { described_class.new(submission).output_file.path }
  let(:pdf_fields) { filled_in_values(file_path) }

  describe "#hash_for_pdf" do
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end
  describe "child care credit amount" do
    context "when TotalQlfdExpensesOrLimitAmt is least" do
      before do
        intake.direct_file_data.total_qualified_expenses_or_limit_amount = 200
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with qualified expenses amount' do
        expect(pdf_fields["BL6"]).to eq "200"
      end
    end

    context "when ExcludedBenefitsAmt is least after subtracting from 12,000" do
      before do
        intake.direct_file_data.total_qualified_expenses_or_limit_amount = 500
        intake.direct_file_data.excluded_benefits_amount = 11_800
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with excluded benefits amount' do
        expect(pdf_fields["BL6"]).to eq "200"
      end
    end

    context "when ExcludedBenefitsAmt is greater than 12,000" do
      before do
        intake.direct_file_data.total_qualified_expenses_or_limit_amount = 500
        intake.direct_file_data.excluded_benefits_amount = 12_800
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with excluded benefits amount' do
        expect(pdf_fields["BL6"]).to eq "0"
      end
    end

    context "when PrimaryEarnedIncomeAmt is least" do
      before do
        intake.direct_file_data.total_qualified_expenses_or_limit_amount = 500
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 200
        intake.direct_file_data.spouse_earned_income_amount = 500
      end

      it 'should expect to fill with primary earned income amount' do
        expect(pdf_fields["BL6"]).to eq "200"
      end
    end

    context "when SpouseEarnedIncomeAmt is least" do
      before do
        intake.direct_file_data.total_qualified_expenses_or_limit_amount = 500
        intake.direct_file_data.excluded_benefits_amount = 500
        intake.direct_file_data.primary_earned_income_amount = 500
        intake.direct_file_data.spouse_earned_income_amount = 200
      end

      it 'should expect to fill with primary earned income amount' do
        expect(pdf_fields["BL6"]).to eq "200"
      end
    end
  end
end
