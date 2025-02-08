require 'rails_helper'

RSpec.describe PdfFiller::Az322Pdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: create(:state_file_az_intake, :with_az322_contributions) }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf', required_schema: "az" do
    let!(:pdf_fields) { filled_in_values(described_class.new(submission).output_file.path) }
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it "sets other fields to the correct values" do
      expect(pdf_fields['TP_Name']).to eq 'Ariz  Onian '
      expect(pdf_fields['TP_SSN']).to eq '555002222'
      expect(pdf_fields['Spouse_Name']).to eq ""
      expect(pdf_fields['Spouse_SSN']).to eq ""
      expect(pdf_fields['4h']).to eq '900'
      expect(pdf_fields['4']).to eq '900'
      expect(pdf_fields['5']).to eq '1500'
      expect(pdf_fields['9']).to eq '0'
      expect(pdf_fields['10']).to eq '0'
      expect(pdf_fields['11']).to eq '1500'
      expect(pdf_fields['12']).to eq '200'
      expect(pdf_fields['13']).to eq '200'
      expect(pdf_fields['20']).to eq '200'
      expect(pdf_fields['22']).to eq '200'
    end
  end
end

