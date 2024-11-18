require 'rails_helper'

RSpec.describe PdfFiller::Az301Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_az_intake, :with_az321_contributions, :with_az322_contributions) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let!(:pdf_fields) { filled_in_values(described_class.new(submission.reload).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      let(:intake) { create(:state_file_az_intake, :with_az321_contributions, :with_az322_contributions) }

      it "sets other fields to the correct values" do
        expect(pdf_fields['FY_Beg']).to eq '0101'
        expect(pdf_fields['FY_End']).to eq "1231#{Rails.configuration.statefile_current_tax_year}"
        expect(pdf_fields['Tp_Name']).to eq 'Ariz  Onian '
        expect(pdf_fields['Tp_SSN']).to eq '555002222'
        expect(pdf_fields['6a']).to eq '470'
        expect(pdf_fields['6c']).to eq '470'
        expect(pdf_fields['7a']).to eq '200'
        expect(pdf_fields['7c']).to eq '200'
        expect(pdf_fields['26']).to eq '670'
        expect(pdf_fields['27']).to eq '2442'
        expect(pdf_fields['32']).to eq '2442'
        expect(pdf_fields['33']).to eq '0'
        expect(pdf_fields['34']).to eq '2442'
        expect(pdf_fields['60']).to eq '670'
        expect(pdf_fields['62']).to eq '670'
      end
    end
  end
end
