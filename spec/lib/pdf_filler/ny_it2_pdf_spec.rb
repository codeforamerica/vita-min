require 'rails_helper'

RSpec.describe PdfFiller::NyIt2Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_ny_intake) }
  let(:w2) { create :w2}
  let(:pdf) { described_class.new(submission, w2) }

  describe '#hash_for_pdf' do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values(submission.generate_filing_pdf.path)
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end
end
