require 'rails_helper'

RSpec.describe PdfFiller::Ny213Pdf do
  include PdfSpecHelper

  let(:submission) { 
    create :efile_submission,
           tax_return: nil,
           data_source: create(:state_file_ny_intake,
                               eligibility_lived_in_state: 1, dependents: [create(:state_file_dependent,
                                                                                  dob: 7.years.ago)])
  }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    it 'uses field names that exist in the pdf' do
      pdf_fields = filled_in_values(submission.generate_filing_pdf.path)
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end
  end
end
