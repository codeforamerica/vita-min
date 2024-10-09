require "rails_helper"

RSpec.describe PdfFiller::Md502Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it "uses field names that exist in the pdf" do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      let(:intake) { create(:state_file_md_intake) }

      context "when total interest is > $11,600" do
        before do
          intake.direct_file_data.fed_agi = 100
          intake.direct_file_data.fed_wages_salaries_tips = 101
          intake.direct_file_data.fed_taxable_pensions = 102
          intake.direct_file_data.fed_taxable_income = 11_599
          intake.direct_file_data.fed_tax_exempt_interest = 2
        end

        it "fills out income fields correctly" do
          expect(pdf_fields["Enter 1"].to_i).to eq intake.direct_file_data.fed_agi
          expect(pdf_fields["Enter 1a"].to_i).to eq intake.direct_file_data.fed_wages_salaries_tips
          expect(pdf_fields["Enter 1b"].to_i).to eq intake.direct_file_data.fed_wages_salaries_tips
          expect(pdf_fields["Enter 1dEnter 1d"].to_i).to eq intake.direct_file_data.fed_taxable_pensions
          expect(pdf_fields["Enter Y of income more than $11,000"]).to eq("Y")
        end
      end

      context "when total interest is <= $11,600" do
        before do
          intake.direct_file_data.fed_taxable_income = 11_599
          intake.direct_file_data.fed_tax_exempt_interest = 1
        end

        it "fills out income fields correctly" do
          expect(pdf_fields["Enter Y of income more than $11,000"]).to eq("")
        end
      end
    end
  end
end
