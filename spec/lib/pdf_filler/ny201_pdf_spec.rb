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
        expect(ruby_field_options.values).to match_array(file_field_options - ["Off"])
      end
    end
  end

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it 'sets static fields to the correct values' do
      expect(pdf_fields['TP_mail_state']).to eq 'NY'
      expect(pdf_fields['Foreign_account']).to eq 'no'
      expect(pdf_fields['yonkers_freeze_credit']).to eq 'no'
    end

    context 'when primary and spouse dobs are set' do
      before do
        submission.data_source.direct_file_data.filing_status = 2
        submission.data_source.primary_birth_date = Date.parse("1978-04-01")
        submission.data_source.spouse_birth_date = Date.parse("1979-05-01")
      end

      it 'fills dob fields with the correct date format' do
        expect(pdf_fields['TP_DOB']).to eq '04011978'
        expect(pdf_fields['Spouse_DOB']).to eq '05011979'
      end
    end

    context 'when the filing status is married filing separately' do
      before do
        submission.data_source.direct_file_data.filing_status = 3
        submission.data_source.direct_file_data.spouse_ssn = '555123456'
      end
      it 'fills in the spouse SSN field correctly' do
        expect(pdf_fields['Spouse_SSN']).to eq '555123456'
      end
    end
  end
end
