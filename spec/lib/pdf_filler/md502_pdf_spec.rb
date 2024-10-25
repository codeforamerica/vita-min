require "rails_helper"

RSpec.describe PdfFiller::Md502Pdf do
  include PdfSpecHelper

  let(:intake) { create(:state_file_md_intake) }
  let(:submission) { create :efile_submission, tax_return: nil, data_source: intake }
  let(:pdf) { described_class.new(submission) }

  describe "#hash_for_pdf" do
    let(:file_path) { described_class.new(submission).output_file.path }
    let(:pdf_fields) { filled_in_values(file_path) }
    let(:intake) { create(:state_file_md_intake) }

    it 'uses field names that exist in the pdf' do
      missing_fields = pdf.hash_for_pdf.keys.map { |k| k.to_s.gsub("'", "&apos;").to_s } - pdf_fields.keys
      expect(missing_fields).to eq([])
    end

    context "county information" do
      before do
        intake.residence_county = "Allegany"
        intake.political_subdivision = "Town Of Barton"
        intake.subdivision_code = "0101"
      end

      it "output correct information" do
        expect(pdf_fields["Enter 4 Digit Political Subdivision Code (See Instruction 6)"]).to eq("0101")
        expect(pdf_fields["Enter Maryland Political Subdivision (See Instruction 6)"]).to eq("Town Of Barton")
        expect(pdf_fields["Enter zip code + 5"]).to eq("Allegany")
      end
    end

    describe "income from interest" do
      context "when total interest is > $11,600" do
        before do
          intake.direct_file_data.fed_agi = 100
          intake.direct_file_data.fed_wages_salaries_tips = 101
          intake.direct_file_data.fed_taxable_pensions = 102
          intake.direct_file_data.fed_taxable_income = 11_599
          intake.direct_file_data.fed_tax_exempt_interest = 2
        end

        it "fills out income fields correctly" do
          expect(pdf_fields["Enter 1"].to_i).to eq intake.direct_file_data.fed_agi
          expect(pdf_fields["Enter 1a"].to_i).to eq intake.direct_file_data.fed_wages_salaries_tips
          expect(pdf_fields["Enter 1b"].to_i).to eq intake.direct_file_data.fed_wages_salaries_tips
          expect(pdf_fields["Enter 1dEnter 1d"].to_i).to eq intake.direct_file_data.fed_taxable_pensions
          expect(pdf_fields["Enter Y of income more than $11,000"]).to eq("Y")
        end
      end

      context "when total interest is <= $11,600" do
        before do
          intake.direct_file_data.fed_taxable_income = 11_599
          intake.direct_file_data.fed_tax_exempt_interest = 1
        end

        it "fills out income fields correctly" do
          expect(pdf_fields["Enter Y of income more than $11,000"]).to eq("")
        end
      end
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

    context "Line A Exemptions" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_primary).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_spouse).and_return nil
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_a_amount).and_return 3200
      end

      it "sets the correct fields for line A" do
        expect(pdf_fields["Check Box 15"]).to eq "Yes" # primary
        expect(pdf_fields["Check Box 18"]).to eq "Off" # spouse
        expect(pdf_fields["Text Field 15"]).to eq "1" # exemption count
        expect(pdf_fields["Enter A $"]).to eq "3200" # exemption amount
      end
    end

    context "Line B Exemptions" do
      let(:intake) { create(:state_file_md_intake, :with_spouse) }

      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_senior).and_return 'X'
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_senior).and_return nil
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_primary_blind).and_return nil
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_b_spouse_blind).and_return 'X'
      end

      it "sets the correct fields for line B" do
        expect(pdf_fields["Check Box 20"]).to eq "Yes" # primary 65+
        expect(pdf_fields["Check Box 21"]).to eq "Off" # spouse 65+
        expect(pdf_fields["B. Check this box if you are blind"]).to eq "Off" # primary blind
        expect(pdf_fields["B. Check this box if your spouse is blind"]).to eq "Yes" # spouse blind
        expect(pdf_fields["B. Enter number exemptions checked B"]).to eq "2" # exemption count
        expect(pdf_fields["Enter B $ "]).to eq "2000" # exemption amount
      end
    end

    context "Line C exemptions" do
      let(:dependent_count) { 1 }
      let(:dependent_exemption_amount) { 3200 }
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_count).and_return dependent_count
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_c_amount).and_return dependent_exemption_amount
      end

      it "sets correct filing status for dependent taxpayer and does not set other filing_status" do
        expect(pdf_fields["Text Field 16"]).to eq dependent_count.to_s
        expect(pdf_fields["Enter C $ "]).to eq dependent_exemption_amount.to_s
      end
    end

    context "Line D Exemptions" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_d_count_total).and_return 3
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_d_amount_total).and_return 3_200
      end

      it "sets the correct fields for line B" do
        expect(pdf_fields["Text Field 17"]).to eq "3" # exemption count total
        expect(pdf_fields["D. Enter Dollar Amount Total Exemptions (Add A, B and C.) "]).to eq "3200" # exemption amount total
      end
    end

    context "subtractions" do
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses = 1200
        intake.direct_file_data.fed_taxable_ssb = 240
      end

      it "fills out subtractions fields correctly" do
        expect(pdf_fields["Enter 9"].to_i).to eq intake.direct_file_data.total_qualifying_dependent_care_expenses
        expect(pdf_fields["Enter 11"].to_i).to eq intake.direct_file_data.fed_taxable_ssb
      end
    end
  end
end
