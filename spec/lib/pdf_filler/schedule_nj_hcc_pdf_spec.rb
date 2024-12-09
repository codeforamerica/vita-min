require 'rails_helper'

RSpec.describe PdfFiller::ScheduleNjHccPdf do
  include PdfSpecHelper

  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }
    let(:intake) { create(:state_file_nj_intake)}

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it 'fills Choice1 for Part 1 checkbox' do
      expect(pdf_fields["Group1"]).to eq "Choice1"
    end

    context 'when single' do
      let(:intake) { 
        create(
        :state_file_nj_intake,
        :df_data_minimal,
        eligibility_all_members_health_insurance: "yes"
      )}

      it 'fills in name and SSN from XML' do
        expect(pdf_fields["Names as shown on Form NJ1040"]).to eq "Yarn Mat Beaches T"
        expect(pdf_fields["Social Security Number"]).to eq "123456789"
      end
    end

    context 'when filing jointly' do
      let(:intake) { 
        create(
        :state_file_nj_intake,
        :df_data_mfj,
        eligibility_all_members_health_insurance: "yes"
      )}

      it 'fills in both names and primary SSN from XML' do
        expect(pdf_fields["Names as shown on Form NJ1040"]).to eq "Muppet Ernie & Bert K"
        expect(pdf_fields["Social Security Number"]).to eq "400000031"
      end
    end
  end
end