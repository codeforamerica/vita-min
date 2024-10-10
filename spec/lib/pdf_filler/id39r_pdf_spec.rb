require 'rails_helper'

RSpec.describe PdfFiller::Id39rPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_id_intake) }
  let!(:dependents) do
    [
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "One", ssn: "123456789", dob: Date.new(2010, 1, 1)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Two", ssn: "987654321", dob: Date.new(2012, 2, 2)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Three", ssn: "456789123", dob: Date.new(2014, 3, 3)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Four", ssn: "321654987", dob: Date.new(2016, 4, 4)),
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Five", ssn: "789123456", dob: Date.new(2018, 5, 5))
    ]
  end
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    it 'includes correct dependent information' do
      result = pdf.hash_for_pdf

      expect(result['FR1FirstName']).to eq 'Child'
      expect(result['FR1LastName']).to eq 'Five'
      expect(result['FR1SSN']).to eq '789123456'
      expect(result['FR1Birthdate']).to eq '05/05/2018'

      expect(result['FR2FirstName']).to be_nil
      expect(result['FR2LastName']).to be_nil
      expect(result['FR2SSN']).to be_nil
      expect(result['FR2Birthdate']).to be_nil

      expect(result['FR3FirstName']).to be_nil
      expect(result['FR3LastName']).to be_nil
      expect(result['FR3SSN']).to be_nil
      expect(result['FR3Birthdate']).to be_nil
    end
  end
end

