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

    context "US address from df" do
      it "fills in correct fields" do
        intake.direct_file_data.mailing_street = "312 Poppy Street"
        intake.direct_file_data.mailing_apartment = "Apt B"
        intake.direct_file_data.mailing_city = "Annapolis"
        intake.direct_file_data.mailing_state = "MD"
        intake.direct_file_data.mailing_zip = "21401"

        expect(pdf_fields["Enter Current Mailing Address Line 1 (Street No. and Street Name or PO Box)"]).to eq("312 Poppy Street")
        expect(pdf_fields["Enter Current Mailing Address Line 2 (Street No. and Street Name or PO Box)"]).to eq("Apt B")
        expect(pdf_fields["Enter city or town"]).to eq("Annapolis")
        expect(pdf_fields["Enter state"]).to eq("MD")
        expect(pdf_fields["Enter zip code + 4"]).to eq("21401")
      end
    end

    context "Physical address" do
      context "when the filer has confirmed their DF address is correct" do
        before do
          intake.confirmed_permanent_address_yes!
          intake.direct_file_data.mailing_street = "312 Poppy Street"
          intake.direct_file_data.mailing_apartment = "Apt B"
          intake.direct_file_data.mailing_city = "Annapolis"
          intake.direct_file_data.mailing_state = "MD"
          intake.direct_file_data.mailing_zip = "21401"
        end

        it "fills the fields with the DF address" do
          expect(pdf_fields["Enter Maryland Physical Address Line 1 (Street No. and Street Name) (No PO Box)"]).to eq("312 Poppy Street")
          expect(pdf_fields["Enter Maryland Physical Address Line 2 (Street No. and Street Name) (No PO Box)"]).to eq("Apt B")
          expect(pdf_fields["Enter city"]).to eq("Annapolis")
          expect(pdf_fields["2 Enter zip code + 4"]).to eq("21401")
        end
      end

      context "when the filer has entered a different physical address" do
        before do
          intake.confirmed_permanent_address_no!

          intake.permanent_street = "313 Poppy Street"
          intake.permanent_apartment = "Apt A"
          intake.permanent_city = "Baltimore"
          intake.permanent_zip = "21201"
        end

        it "fills the fields with the entered address" do
          expect(pdf_fields["Enter Maryland Physical Address Line 1 (Street No. and Street Name) (No PO Box)"]).to eq("313 Poppy Street")
          expect(pdf_fields["Enter Maryland Physical Address Line 2 (Street No. and Street Name) (No PO Box)"]).to eq("Apt A")
          expect(pdf_fields["Enter city"]).to eq("Baltimore")
          expect(pdf_fields["2 Enter zip code + 4"]).to eq("21201")
        end
      end
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
          expect(pdf_fields["Enter day and month of Fiscal Year beginning"]).to be_nil
          expect(pdf_fields["Enter day and month of Fiscal Year Ending"]).to be_nil
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
          expect(pdf_fields['Enter social security number']).to eq("123456789")
          expect(pdf_fields["Enter spouse&apos;s social security number"]).to eq("987654321")
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
          expect(pdf_fields["Enter social security number"]).to eq("123456789")
          expect(pdf_fields["Enter your first name"]).to eq("Mary")
          expect(pdf_fields["Enter your middle initial"]).to eq("A")
          expect(pdf_fields["Enter your last name"]).to eq("Lando")
          expect(pdf_fields["Check Box - 1"]).to eq "Off"
          expect(pdf_fields["Check Box - 2"]).to eq "Off"
          expect(pdf_fields["Check Box - 3"]).to eq "No"
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

    context "healthcare coverage" do
      before do
        intake.update(primary_did_not_have_health_insurance: true)
        intake.update(primary_birth_date: DateTime.new(1975, 4, 12))
        intake.update(spouse_did_not_have_health_insurance: true)
        intake.update(spouse_birth_date: DateTime.new(1972, 11, 5))
        intake.update(authorize_sharing_of_health_insurance_info: "yes")
        intake.update(email_address: "healthy@example.com")
      end

      it "fills the correct fields" do
        expect(pdf_fields["Check Box 27"]).to eq "Yes"
        expect(pdf_fields["Check Box 28"]).to eq "Yes"
        expect(pdf_fields["Enter DOB if you have no healthcare"]).to eq "04/12/1975"
        expect(pdf_fields["Enter DOB if your spouse has no healthcare"]).to eq "11/05/1972"
        expect(pdf_fields["Check Box 29"]).to eq "Yes"
        expect(pdf_fields["Enter email addressEnter DOB if your spouse has no healthcare 2"]).to eq "healthy@example.com"
      end
    end

    context "subtractions" do
      let(:two_income_subtraction_amount) { 1200 }
      before do
        intake.direct_file_data.total_qualifying_dependent_care_expenses_or_limit_amt = 1200
        intake.direct_file_data.fed_taxable_ssb = 240
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_14).and_return two_income_subtraction_amount
      end

      it "fills out subtractions fields correctly" do
        expect(pdf_fields["Enter 9"].to_i).to eq 1200
        expect(pdf_fields["Enter 11"].to_i).to eq 240
        expect(pdf_fields["Enter 14"].to_i).to eq two_income_subtraction_amount
      end

      context "with 502SU Subtractions" do
        before do
          allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_1).and_return 100
          allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return 100
        end

        it "fills out subtractions fields correctly" do
          expect(pdf_fields["Text Field 9"]).to eq "ab"
          expect(pdf_fields["Text Field 10"]).to eq ""
          expect(pdf_fields["Text Field 11"]).to eq ""
          expect(pdf_fields["Text Field 12"]).to eq ""
          expect(pdf_fields["Enter 13"].to_i).to eq 100
        end
      end

      context "without 502SU Subtractions" do
        it "fills out subtractions fields correctly" do
          expect(pdf_fields["Text Field 9"]).to eq ""
          expect(pdf_fields["Text Field 10"]).to eq ""
          expect(pdf_fields["Text Field 11"]).to eq ""
          expect(pdf_fields["Text Field 12"]).to eq ""
          expect(pdf_fields["Enter 13"].to_i).to eq 0
        end
      end

      describe "Line 15" do
        let(:total_subtractions) { 100 }
        it "outputs the total subtractions" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_15).and_return total_subtractions
          expect(pdf_fields["Enter 15"].to_i).to eq total_subtractions
        end
      end

      describe "Line 16" do
        let(:state_adjusted_gross_income) { 150 }
        it "outputs the total subtractions" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_16).and_return state_adjusted_gross_income
          expect(pdf_fields["Enter 16"].to_i).to eq state_adjusted_gross_income
        end
      end
    end

    context "deduction" do
      context "method" do
        it "checks box if standard deduction" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
          expect(pdf_fields["Check Box 34"]).to eq "Yes"
        end

        it "does not check box if non-standard deduction" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
          expect(pdf_fields["Check Box 34"]).to eq "Off"
        end
      end

      context "amount" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_17).and_return 500
        end

        it "fills out amount if method is standard" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
          expect(pdf_fields["Enter 17"]).to eq "500"
        end

        it "leaves amount blank if method is not standard" do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
          expect(pdf_fields["Enter 17"]).to be_empty
        end
      end
    end

    context "tax computation" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_18).and_return 50
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_19).and_return 60
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_20).and_return 70
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_21).and_return 80
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_23).and_return 200
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_24).and_return 100
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_26).and_return 300
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_27).and_return 0
      end

      it "fills out amount if deduction method is standard" do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
        expect(pdf_fields["Enter 18"]).to eq "50"
        expect(pdf_fields["Enter 19 "]).to eq "60"
        expect(pdf_fields["Enter 20"]).to eq "70"
        expect(pdf_fields["Text Box 30"]).to eq "80"
        expect(pdf_fields["Text Box 36"]).to eq "200"
        expect(pdf_fields["Text Box 38"]).to eq "100"
        expect(pdf_fields["Text Box 40"]).to eq "300"
        expect(pdf_fields["Text Box 42"]).to eq "0"
      end

      it "leaves amount blank if deduction method is not standard" do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
        expect(pdf_fields["Enter 18"]).to be_empty
        expect(pdf_fields["Enter 20"]).to be_empty
      end
    end

    context "additions" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_3).and_return 40
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_6).and_return 50
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_7).and_return 60
      end

      it "fills out amount if deduction method is standard" do
        expect(pdf_fields["Enter 3"]).to eq "40"
        expect(pdf_fields["Enter 6"]).to eq "50"
        expect(pdf_fields["Enter 7"]).to eq "60"
      end
    end

    context "EIC" do
      context "there are qualifying children and state EIC" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return 100
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22b).and_return "X"
        end

        it "fills out EIC fields correctly" do
          expect(pdf_fields["Text Box 34"]).to eq "100"
          expect(pdf_fields["Check Box 37"]).to eq "Yes"
        end
      end

      context "there are NOT qualifying children and no state EIC" do
        before do
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return nil
          allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22b).and_return nil
        end

        it "doesn't fill out the EIC fields" do
          expect(pdf_fields["Text Box 34"]).to eq ""
          expect(pdf_fields["Check Box 37"]).to eq "Off"
        end
      end
    end

    context "Line 40: Total state and local tax withheld" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_40).and_return 500
      end

      it 'outputs the total state and local tax withheld' do
        expect(pdf_fields["Text Box 68"]).to eq "500"
        expect(pdf_fields["Text Box 69"]).to eq "00"
      end
    end

    context "Contributions Sections" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_39).and_return 100
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_42).and_return 200
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_44).and_return 300
      end

      it 'outputs the total state and local tax withheld' do
        expect(pdf_fields["Text Box 66"]).to eq "100"
        expect(pdf_fields["Text Box 67"]).to eq "00"
        expect(pdf_fields["Text Box 72"]).to eq "200"
        expect(pdf_fields["Text Box 73"]).to eq "00"
        expect(pdf_fields["Text Box 76"]).to eq "300"
        expect(pdf_fields["Text Box 77"]).to eq "00"
      end
    end

    context "when taxes are owed" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_45).and_return 100
      end

      it 'outputs the amount owed' do
        expect(pdf_fields["Text Box 78"]).to eq "100"
        expect(pdf_fields["Text Box 79"]).to eq "00"
        expect(pdf_fields["Text Box 91"]).to eq "100"
        expect(pdf_fields["Text Box 92"]).to eq "00"
      end
    end

    context "when there is a refund" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_46).and_return 300
      end

      it 'outputs the amount to be refunded' do
        expect(pdf_fields["Text Box 80"]).to eq "300"
        expect(pdf_fields["Text Box 81"]).to eq "00"
        expect(pdf_fields["Text Box 84"]).to eq "300"
        expect(pdf_fields["Text Box 85"]).to eq "00"
      end
    end

    context "Direct deposit of refund" do
      before do
        intake.update(
          payment_or_deposit_type: :direct_deposit,
          routing_number: "123456789",
          account_number: "87654321",
          account_type: "checking",
          account_holder_first_name: "Jack",
          account_holder_middle_initial: "D",
          account_holder_last_name: "Hansel",
          has_joint_account_holder: "unfilled",
          bank_authorization_confirmed: "yes"
        )
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:refund_or_owed_amount).and_return 500
      end

      context "bank_authorization_confirmed is empty" do
        before do
          intake.update(bank_authorization_confirmed: 'unfilled')
        end

        it "return Off" do
          expect(pdf_fields["Check Box 39"]).to eq "Off"
        end
      end

      it "checks the refund information with the account holder's full name" do
        expect(pdf_fields["Check Box 39"]).to eq "Yes"
        expect(pdf_fields["Text Box 95"]).to eq "Jack D Hansel"
        expect(pdf_fields["Check Box 41"]).to eq "Yes"
        expect(pdf_fields["Check Box 42"]).to eq "Off"
        expect(pdf_fields["Text Box 93"]).to eq "123456789"
        expect(pdf_fields["Text Box 94"]).to eq "87654321"
      end

      context "with joint account holder" do
        before do
          intake.joint_account_holder_first_name = "Jill"
          intake.joint_account_holder_last_name = "Gretl"
          intake.joint_account_holder_suffix = "II"
          intake.has_joint_account_holder = "yes"
          intake.bank_authorization_confirmed = "yes"
        end

        it "returns the same information including joint account holder's full name with an 'and'" do
          expect(pdf_fields["Check Box 39"]).to eq "Yes"
          expect(pdf_fields["Text Box 95"]).to eq "Jack D Hansel and Jill Gretl II"
          expect(pdf_fields["Check Box 41"]).to eq "Yes"
          expect(pdf_fields["Check Box 42"]).to eq "Off"
          expect(pdf_fields["Text Box 93"]).to eq "123456789"
          expect(pdf_fields["Text Box 94"]).to eq "87654321"
        end
      end
    end

    context "Line 43: Refundable income tax credits from Part CC" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_43).and_return 400
      end

      it 'outputs the total refundable credit' do
        expect(pdf_fields["Text Box 74"]).to eq "400"
      end
    end

    context "local tax computations" do
      before do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_28_local_tax_rate).and_return 0.027
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_28_local_tax_amount).and_return 8765
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_29).and_return 1200
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_30).and_return 1250
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_32).and_return 1300
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_33).and_return 1400
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_34).and_return 1500
      end

      it "fills out local tax computation fields correctly" do
        expect(pdf_fields["Enter local tax rate"]).to eq "27"
        expect(pdf_fields["Text Box 44"]).to eq "8765"
        expect(pdf_fields["Text Box 46"]).to eq "1200"
        expect(pdf_fields["Text Box 48"]).to eq "1250"
        expect(pdf_fields["Text Box 52"]).to eq "1300"
        expect(pdf_fields["Text Box 54"]).to eq "1400"
        expect(pdf_fields["Text Box 56"]).to eq "1500"
      end
    end
  end
end
