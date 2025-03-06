require 'rails_helper'

RSpec.describe PdfFiller::NcD400ScheduleSPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_nc_intake, tribal_member: "yes", tribal_wages_amount: 500.00, primary_last_name: "Carroll", primary_suffix: "JR") }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      it 'sets fields to the correct values' do
        allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_20).and_return 100
        allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_21).and_return 200

        expect(pdf_fields['y_d400schswf_ssn']).to eq '145004904'
        expect(pdf_fields['y_d400wf_lname2_PG2']).to eq 'Carroll JR'
        expect(pdf_fields['y_d400schswf_li18_good']).to eq '0'
        expect(pdf_fields['y_d400schswf_li19_good']).to eq '0'
        expect(pdf_fields['y_d400schswf_li20_good']).to eq '100'
        expect(pdf_fields['y_d400schswf_li21_good']).to eq '200'
        expect(pdf_fields['y_d400schswf_li27_good']).to eq '500'
        expect(pdf_fields['y_d400schswf_li41_good']).to eq '800'
      end
    end
  end
end
