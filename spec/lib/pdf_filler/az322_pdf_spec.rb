require 'rails_helper'

RSpec.describe PdfFiller::Az322Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_az_intake, :with_az322_contributions) }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf', required_schema: "az" do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values(submission.generate_filing_pdf.path)
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end
end

