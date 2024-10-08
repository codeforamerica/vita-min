require 'rails_helper'

RSpec.describe PdfFiller::Md502Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe '#hash_for_pdf' do
    let(:file_path) { described_class.new(submission.reload).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    # We usually expect "Yes" to be the "checked" option in PDFs, but for this field "No" means checked.
    # This test is to ensure when fixtures change, change is made to the corresponding has_for_pdf value
    # on this field from "No" to "Yes"
    it "pdf contains 'No' option for mfs checkbox" do
      expect(check_if_valid_pdf_option(file_path, "Check Box - 3", "No")).to eq(true)
      expect(check_if_valid_pdf_option(file_path, "6. Check here", "No")).to eq(true)
    end

    describe "filing_status" do
      context "single" do
        it "sets correct value for the single filer and leaves it empty for spouse" do
          expect(pdf_fields["Enter day and month of Fiscal Year beginning"]).to eq '01-01'
          expect(pdf_fields["Enter day and month of Fiscal Year Ending"]).to eq "12-31"
          expect(pdf_fields["Enter social security number"]).to eq("123456789")
          expect(pdf_fields["Enter spouse's social security number"]).to be_nil
          expect(pdf_fields["Enter your first name"]).to eq("Mary")
          expect(pdf_fields["Enter your middle initial"]).to eq("A")
          expect(pdf_fields["Enter your last name"]).to eq("Lando")
          expect(pdf_fields["Enter Spouse's First Name"]).to be_nil
          expect(pdf_fields["Enter Spouse's middle initial"]).to be_nil
          expect(pdf_fields["Enter Spouse's last name"]).to be_nil
          expect(pdf_fields["Check Box - 1"]).to eq "Yes"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "Off"
          expect(pdf_fields["MARRIED FILING Enter spouse&apos;s social security number"]).to eq("")
          expect(pdf_fields["Check Box - 4"]).to eq "Off"
          expect(pdf_fields["Check Box - 5"]).to eq "Off"
          expect(pdf_fields["6. Check here"]).to eq "Off"
          expect(pdf_fields["Text Box 96"]).to eq("5551234567")
        end
      end

      context "mfj" do
        let(:intake) { create(:state_file_md_intake, :with_spouse) }

        it "sets correct values for mfj filers" do
          expect(pdf_fields['Enter social security number']).to eq("400000030")
          expect(pdf_fields["Enter spouse&apos;s social security number"]).to eq("600000030")
          expect(pdf_fields["Enter your first name"]).to eq("Mary")
          expect(pdf_fields["Enter your middle initial"]).to eq("A")
          expect(pdf_fields["Enter your last name"]).to eq("Lando")
          expect(pdf_fields["Enter Spouse&apos;s First Name"]).to eq("Marty")
          expect(pdf_fields["Enter Spouse&apos;s middle initial"]).to eq("B")
          expect(pdf_fields["Enter Spouse&apos;s last name"]).to eq("Lando")
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Yes"
          expect(pdf_fields["Check Box - 3"]).to eq "Off"
          expect(pdf_fields["MARRIED FILING Enter spouse&apos;s social security number"]).to eq("")
          expect(pdf_fields["Check Box - 4"]).to eq "Off"
          expect(pdf_fields["Check Box - 5"]).to eq "Off"
          expect(pdf_fields["6. Check here"]).to eq "Off"
        end
      end

      context "mfs" do
        let(:intake) { create(:state_file_md_intake, :with_spouse, filing_status: "married_filing_separately") }

        it "sets correct values for filer and fills in mfs spouse ssn" do
          expect(pdf_fields["Enter social security number"]).to eq("400000030")
          expect(pdf_fields["Enter spouse&apos;s social security number"]).to eq("600000030")
          expect(pdf_fields["Enter your first name"]).to eq("Mary")
          expect(pdf_fields["Enter your middle initial"]).to eq("A")
          expect(pdf_fields["Enter your last name"]).to eq("Lando")
          expect(pdf_fields["Enter Spouse&apos;s First Name"]).to eq("Marty")
          expect(pdf_fields["Enter Spouse&apos;s middle initial"]).to eq("B")
          expect(pdf_fields["Enter Spouse&apos;s last name"]).to eq("Lando")
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "No"
          expect(pdf_fields["MARRIED FILING Enter spouse&apos;s social security number"]).to eq("600000030")
          expect(pdf_fields["Check Box - 4"]).to eq "Off"
          expect(pdf_fields["Check Box - 5"]).to eq "Off"
          expect(pdf_fields["6. Check here"]).to eq "Off"
        end
      end

      context "hoh" do
        let(:intake) { create(:state_file_md_intake, :head_of_household) }

        it "sets correct filing status for hoh" do
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "Off"
          expect(pdf_fields["Check Box - 4"]).to eq "Yes"
          expect(pdf_fields["Check Box - 5"]).to eq "Off"
          expect(pdf_fields["6. Check here"]).to eq "Off"
        end
      end

      context "qw" do
        let(:intake) { create(:state_file_md_intake, :qualifying_widow) }

        it "sets correct filing status for qw" do
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "Off"
          expect(pdf_fields["Check Box - 4"]).to eq "Off"
          expect(pdf_fields["Check Box - 5"]).to eq "Yes"
          expect(pdf_fields["6. Check here"]).to eq "Off"
        end
      end

      context "dependent taxpayer" do
        let(:intake) { create(:state_file_md_intake, :claimed_as_dependent) }

        it "sets correct filing status for dependent taxpayer and does not set other filing_status" do
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "Off"
          expect(pdf_fields["Check Box - 4"]).to eq "Off"
          expect(pdf_fields["Check Box - 5"]).to eq "Off"
          expect(pdf_fields["6. Check here"]).to eq "No"
        end
      end
    end
  end
end
