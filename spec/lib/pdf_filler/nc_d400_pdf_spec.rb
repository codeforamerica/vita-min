require 'rails_helper'

RSpec.describe PdfFiller::NcD400Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_nc_intake) }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    xit 'sets static fields to the correct values' do
      expect(pdf_fields['']).to eq ''
    end
  end
end
