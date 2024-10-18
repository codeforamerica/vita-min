require 'rails_helper'

RSpec.describe PdfFiller::Id39rAdditionalDependentsPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_id_intake) }
  let(:dependents) do
    [
      create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "One", ssn: "123456789", dob: Date.new(2010, 1, 1))
    ]
  end
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission, { dependents: dependents }) }

  describe '#hash_for_pdf' do
    let(:pdf_fields) { filled_in_values(described_class.new(submission, { dependents: dependents }).output_file.path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "with more than 7 dependents" do
      let(:dependents) do
        [
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Eight", ssn: "123456789", dob: Date.new(2010, 1, 1)),
          create(:state_file_dependent, intake: intake, first_name: "Child", last_name: "Nine", ssn: "987654321", dob: Date.new(2012, 2, 2)),
         ]
      end

      it "sets dependent fields correctly for dependents after the first 7" do
        result = pdf.hash_for_pdf

        expect(result['FR1FirstName']).to eq 'Child'
        expect(result['FR1LastName']).to eq 'Eight'
        expect(result['FR1SSN']).to eq '123456789'
        expect(result['FR1Birthdate']).to eq '01/01/2010'

        expect(result['FR2FirstName']).to eq 'Child'
        expect(result['FR2LastName']).to eq 'Nine'
        expect(result['FR2SSN']).to eq '987654321'
        expect(result['FR2Birthdate']).to eq '02/02/2012'

        expect(result['FR3FirstName']).to eq nil
        expect(result['FR3LastName']).to eq nil
        expect(result['FR3SSN']).to eq nil
        expect(result['FR3Birthdate']).to eq nil
      end
    end

    context "with 7 or fewer dependents" do

      let(:dependents) { [] }

      it "returns an empty hash" do
        result = pdf.hash_for_pdf
        expect(result).to be_empty
      end
    end
  end
end