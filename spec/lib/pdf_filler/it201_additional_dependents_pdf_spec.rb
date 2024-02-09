require 'rails_helper'

RSpec.describe PdfFiller::It201AdditionalDependentsPdf do
  include PdfSpecHelper
  let(:intake) { create(:state_file_zeus_intake) }

  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values("app/lib/pdfs/it201_additional_dependents.pdf")
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it 'includes the name(s) as shown on return' do
      expect(pdf.hash_for_pdf[:'Names as shown on returnRow1']).to eq("New Yorker")
    end

    it 'includes the spouse nameas shown on return' do
      intake.direct_file_data.filing_status = 2
      intake.spouse_first_name = "Old"
      intake.spouse_last_name = "Yorker"
      expect(pdf.hash_for_pdf[:'Names as shown on returnRow1']).to eq("New Yorker and Old Yorker")
    end
  end
end
