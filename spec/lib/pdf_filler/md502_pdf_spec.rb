require 'rails_helper'

RSpec.describe PdfFiller::Md502Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_az_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let!(:pdf_fields) { filled_in_values(described_class.new(submission.reload).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      it "sets other fields to the correct values" do
        expect(pdf_fields['Enter day and month of Fiscal Year beginning']).to eq '01-01'
        expect(pdf_fields['Enter day and month of Fiscal Year Ending']).to eq "12-31"
      end
    end
  end
end
