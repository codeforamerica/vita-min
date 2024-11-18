require 'rails_helper'

RSpec.describe PdfFiller::Az321Pdf do
  include PdfSpecHelper

  let(:submission) do
      create :efile_submission, 
             tax_return: nil, 
             data_source: create(:state_file_az_intake, :with_az321_contributions) 
  end
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let!(:pdf_fields) { filled_in_values(described_class.new(submission.reload).output_file.path) }
    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it "sets other fields to the correct values" do
      expect(pdf_fields['FY_Beg']).to eq '0101'
      expect(pdf_fields['FY_End']).to eq "1231#{MultiTenantService.new(:statefile).current_tax_year}"
      expect(pdf_fields['TP_Name']).to eq 'Ariz  Onian '
      expect(pdf_fields['TP_SSN']).to eq '555002222'
      expect(pdf_fields['Spouse_Name']).to eq ""
      expect(pdf_fields['Spouse_SSN']).to eq ""
      expect(pdf_fields['4h']).to eq '235'
      expect(pdf_fields['4']).to eq '235'
      expect(pdf_fields['5']).to eq '1211'
      expect(pdf_fields['11']).to eq '1211'
      expect(pdf_fields['12']).to eq '470'
      expect(pdf_fields['13']).to eq '470'
      expect(pdf_fields['20']).to eq '470'
      expect(pdf_fields['22']).to eq '470'
    end
  end
end