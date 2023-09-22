require 'rails_helper'

RSpec.describe PdfFiller::Ny201Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_ny_intake) }
  let(:pdf) { described_class.new(submission) }

  describe 'field mappings' do
    it "uses the available options from the PDF" do
      field_defs = PdfForms.new(utf8_fields: true).get_fields(File.open(Rails.root.join('app', 'lib', 'pdfs', "#{pdf.source_pdf_name}.pdf")).path)

      described_class::FIELD_OPTIONS.each do |pdf_field_name, ruby_field_options|
        file_field_options = field_defs.find { |d| d.name == pdf_field_name }.options

        if pdf_field_name == 'Filing_status'
          # pdftk reports the apostrophe character used in the MFJ option as \u0090 which is wrong.
          # Ultimately we will either edit the PDF or come up with some crazy workaround
          # this is a hack to make the test pass that should someday be destroyed one way or another
          file_field_options.map! { |ffo| ffo.gsub(/\u0090/, '’') }
        end

        expect(ruby_field_options.values).to eq(file_field_options - ["Off"])
      end
    end
  end

  describe '#hash_for_pdf' do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values(submission.generate_filing_pdf.path)
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end
end
