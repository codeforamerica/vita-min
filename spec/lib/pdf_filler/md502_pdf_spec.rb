require 'rails_helper'

RSpec.describe PdfFiller::Md502Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(described_class.new(submission.reload).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "single" do
      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Enter day and month of Fiscal Year beginning']).to eq '01-01'
          expect(pdf_fields['Enter day and month of Fiscal Year Ending']).to eq "12-31"
          expect(pdf_fields['Check Box - 1']).to eq "Yes"
          expect(pdf_fields['Check Box - 2']).to eq "Off"
          expect(pdf_fields['Check Box - 3']).to eq "Off"
          expect(pdf_fields['Check Box - 4']).to eq "Off"
          expect(pdf_fields['Check Box - 5']).to eq "Off"
          expect(pdf_fields['6. Check here']).to eq "Off"
        end
      end
    end

    context "mfj" do
      let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_jointly") }

      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Check Box - 1']).to eq "Off"
          expect(pdf_fields['Check Box - 2']).to eq "Yes"
          expect(pdf_fields['Check Box - 3']).to eq "Off"
          expect(pdf_fields['Check Box - 4']).to eq "Off"
          expect(pdf_fields['Check Box - 5']).to eq "Off"
          expect(pdf_fields['6. Check here']).to eq "Off"
        end
      end
    end

    context "mfs" do
      let(:intake) { create(:state_file_md_intake, filing_status: "married_filing_separately") }

      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Check Box - 1']).to eq "Off"
          expect(pdf_fields['Check Box - 2']).to eq "Off"
          expect(pdf_fields['Check Box - 3']).to eq "Yes"
          expect(pdf_fields['Check Box - 4']).to eq "Off"
          expect(pdf_fields['Check Box - 5']).to eq "Off"
          expect(pdf_fields['6. Check here']).to eq "Off"
        end
      end
    end

    context "hoh" do
      let(:intake) { create(:state_file_md_intake, filing_status: "head_of_household") }

      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Check Box - 1']).to eq "Off"
          expect(pdf_fields['Check Box - 2']).to eq "Off"
          expect(pdf_fields['Check Box - 3']).to eq "Off"
          expect(pdf_fields['Check Box - 4']).to eq "Yes"
          expect(pdf_fields['Check Box - 5']).to eq "Off"
          expect(pdf_fields['6. Check here']).to eq "Off"
        end
      end
    end

    context "qw" do
      let(:intake) { create(:state_file_md_intake, filing_status: "qualifying_widow") }

      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Check Box - 1']).to eq "Off"
          expect(pdf_fields['Check Box - 2']).to eq "Off"
          expect(pdf_fields['Check Box - 3']).to eq "Off"
          expect(pdf_fields['Check Box - 4']).to eq "Off"
          expect(pdf_fields['Check Box - 5']).to eq "Yes"
          expect(pdf_fields['6. Check here']).to eq "Off"
        end
      end
    end

    context "dependent taxpayer" do
      let(:intake) { create(:state_file_md_intake, :claimed_as_dependent, filing_status: "married_filing_jointly") }

      context "pulling fields from xml" do
        it "sets other fields to the correct values" do
          expect(pdf_fields['Check Box - 1']).to eq "Off"
          expect(pdf_fields['Check Box - 2']).to eq "Off"
          expect(pdf_fields['Check Box - 3']).to eq "Off"
          expect(pdf_fields['Check Box - 4']).to eq "Off"
          expect(pdf_fields['Check Box - 5']).to eq "Off"
          expect(pdf_fields['6. Check here']).to eq "Yes"
        end
      end
    end
  end
end
