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

    context "pulling fields from xml" do
      before do
        allow_any_instance_of(SubmissionBuilder::Ty2024::States::Nc::NcReturnXml)
          .to receive(:document)
          .and_return Nokogiri::XML(File.read(Rails.root.join("spec", "fixtures", "state_file", "temp_nc_submission.xml")))
      end

      it 'sets static fields to the correct values' do
        expect(pdf_fields['y_d400wf_datebeg']).to eq '2024-01-01'
        expect(pdf_fields['y_d400wf_dateend']).to eq '2024-12-31'
      end

      it "sets client-specific fields to the correct values" do
        expect(pdf_fields['y_d400wf_fname1']).to eq 'North'
        expect(pdf_fields['y_d400wf_mi1']).to eq 'A'
        expect(pdf_fields['y_d400wf_lname1']).to eq 'Carolinian'
        expect(pdf_fields['y_d400wf_ssn1']).to eq '400000030'
        expect(pdf_fields['y_d400wf_add']).to eq '123 Red Right Hand St Apt 1'
        expect(pdf_fields['y_d400wf_apartment number']).to eq 'Apt 1'
        expect(pdf_fields['y_d400wf_city']).to eq 'Raleigh'
        expect(pdf_fields['y_d400wf_state']).to eq 'NC'
        expect(pdf_fields['y_d400wf_zip']).to eq '27513'
      end
    end
  end
end
