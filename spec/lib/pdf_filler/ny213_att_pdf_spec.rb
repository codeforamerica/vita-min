require 'rails_helper'

RSpec.describe PdfFiller::Ny213AttPdf do
  include PdfSpecHelper

  let(:submission) {
    create :efile_submission,
           tax_return: nil,
           data_source: create(:state_file_zeus_intake, primary_first_name: "Yew", primary_last_name: "Norker")
  }
  let(:pdf) { described_class.new(submission) }

  before do
    submission.data_source.dependents.each_with_index do |dependent, i|
      dependent.update(dob: i.years.ago, middle_initial: "G", relationship: "daughter", ctc_qualifying: true)
    end
  end

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'fills in the overflow dependents only' do
      expect(pdf_fields["Name Shown on Return"]).to eq "Yew Norker"
      expect(pdf_fields["Your SSN"]).to eq "400000015"

      dependent = submission.data_source.dependents[6]

      expect(pdf_fields["1.First Name 1"]).to eq dependent.first_name
      expect(pdf_fields["1.Last Name 1"]).to eq dependent.last_name
      expect(pdf_fields["1.MI 1"]).to eq dependent.middle_initial
      expect(pdf_fields["1.SSN 1"]).to eq dependent.ssn
      expect(pdf_fields["Year of Birth 1.0"]).to eq dependent.dob.strftime("%m%d%Y")
    end
  end
end
