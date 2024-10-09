require 'rails_helper'

RSpec.describe PdfFiller::Md502bPdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, :for_state, data_source: intake }
  let(:pdf) { described_class.new(submission) }
  let(:young_dob) { StateFileDependent.senior_cutoff_date + 60.years }
  let(:old_dob) { StateFileDependent.senior_cutoff_date }
  let!(:dependent) do
    create(
      :state_file_dependent,
      intake: intake,
      first_name: "Janiss",
      middle_initial: "J",
      last_name: "Jawplyn",
      ssn: "123456789",
      relationship: "DAUGHTER",
      dob: young_dob,
      )
  end
  let!(:senior_dependent) do
    create(
      :state_file_dependent,
      intake: intake,
      first_name: "Jeanie",
      middle_initial: "F",
      last_name: "Jimplin",
      ssn: "234567890",
      relationship: "GRANDPARENT",
      dob: old_dob,
      )
  end

  describe "#hash_for_pdf" do
    let(:pdf_fields) { filled_in_values(submission.generate_filing_pdf.path) }

    it "uses field names that exist in the pdf" do
      missing_fields = pdf.hash_for_pdf.keys.map(&:to_s) - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "pulling fields from xml" do
      it "sets fields to the correct values" do
        expect(pdf_fields["No. regular dependents"]).to eq "1"
        expect(pdf_fields["No. 65orOver dependents"]).to eq "1"
        expect(pdf_fields["No. total dependents"]).to eq "2"

        expect(pdf_fields["First Name 1"]).to eq "Janiss"
        expect(pdf_fields["MI 1"]).to eq "J"
        expect(pdf_fields["Last Name 1"]).to eq "Jawplyn"
        expect(pdf_fields["DEPENDENTS SSN 1"]).to eq "123456789"
        expect(pdf_fields["RELATIONSHIP 1"]).to eq "Child"
        expect(pdf_fields["REGULAR 1"]).to eq "Yes"
        expect(pdf_fields["65 OR OLDER 1"]).to eq "Off"
        expect(pdf_fields["DOB date 1_af_date"]).to eq young_dob.strftime("%Y-%m-%d")

        expect(pdf_fields["First Name 2"]).to eq "Jeanie"
        expect(pdf_fields["MI 2"]).to eq "F"
        expect(pdf_fields["Last Name 2"]).to eq "Jimplin"
        expect(pdf_fields["DEPENDENTS SSN 2"]).to eq "234567890"
        expect(pdf_fields["RELATIONSHIP 2"]).to eq "Grandparent"
        expect(pdf_fields["REGULAR 2"]).to eq "Yes"
        expect(pdf_fields["65 OR OLDER 2"]).to eq "2"
        expect(pdf_fields["DOB date 1_af_date 2"]).to eq old_dob.strftime("%Y-%m-%d")
      end
    end
  end
end
