require 'rails_helper'

RSpec.describe PdfFiller::Az140Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_az_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe 'field mappings' do
    it 'uses the available options from the PDF' do
      field_defs = PdfForms.new.get_fields(File.open(Rails.root.join('app', 'lib', 'pdfs', "#{pdf.source_pdf_name}.pdf")).path)

      file_field_options = field_defs.find { |d| d.name == "Filing Status" }.options
      expect(described_class::FILING_STATUS_OPTIONS.values).to eq(file_field_options - ["Off"])
    end
  end

  describe '#hash_for_pdf' do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values(submission.generate_filing_pdf.path)
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it "fills the fields correctly" do
      intake.direct_file_data.interest_reported_amount = 30

      expect(pdf.hash_for_pdf["28"]).to eq "30"
    end
  end
end
