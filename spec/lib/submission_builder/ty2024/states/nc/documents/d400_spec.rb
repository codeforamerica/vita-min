require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nc::Documents::D400, required_schema: "nc" do
  describe ".document" do
    let(:intake) {
      create(:state_file_nc_intake,
             filing_status: "single",
             untaxed_out_of_state_purchases: untaxed_out_of_state_purchases,
             sales_use_tax_calculation_method: 'manual', sales_use_tax: 100)
    }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }
    let(:untaxed_out_of_state_purchases) { "yes" }

    # the single filer block tests all answers that are not specific to filing status
    # the other blocks test only what is specific to that filing status
    context "single filer" do
      let(:income_tax_withheld) { 2000 }
      let(:income_tax_withheld_spouse) { 1000 }
      let(:tax_paid) { 3000 }
      let(:standard_deduction) { 12750 }
      let(:nc_agi_addition) { 18750 }
      let(:nc_agi_subtraction) { 10750 }
      let(:income_tax) { 400 }
      let(:deduction_from_fagi) { 20 }
      before do
        intake.direct_file_data.fed_agi = 10000
        intake.tribal_member = "yes"
        intake.tribal_wages_amount = 100.00
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_11).and_return standard_deduction
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_12a).and_return nc_agi_addition
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_12b).and_return nc_agi_subtraction
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_15).and_return income_tax
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20a).and_return income_tax_withheld
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20b).and_return income_tax_withheld_spouse
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_23).and_return tax_paid
        allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_41).and_return deduction_from_fagi
      end

      it "correctly fills answers" do
        expect(xml.document.at('NCCountyCode')&.text).to eq "001"
        expect(xml.document.at('ResidencyStatusPrimary')&.text).to eq "true"
        expect(xml.document.at('ResidencyStatusSpouse')).to be_nil
        expect(xml.document.at('VeteranInfoSpouse')).to be_nil
        expect(xml.document.at('FederalExtension')&.text).to eq "0"
        expect(xml.document.at('FilingStatus')&.text).to eq "Single"
        expect(xml.document.at('FAGI')&.text).to eq "10000"
        expect(xml.document.at('FAGIPlusAdditions')&.text).to eq "10000"
        expect(xml.document.at('DeductionsFromFAGI')&.text).to eq "20"
        expect(xml.document.at('NCStandardDeduction')&.text).to eq standard_deduction.to_s
        expect(xml.document.at('NCAGIAddition')&.text).to eq nc_agi_addition.to_s
        expect(xml.document.at('NCAGISubtraction')&.text).to eq nc_agi_subtraction.to_s # 12B
        expect(xml.document.at('NCTaxableInc')&.text).to eq nc_agi_subtraction.to_s # 14
        expect(xml.document.at('SubTaxCredFromIncTax')&.text).to eq income_tax.to_s # 15
        expect(xml.document.at('NCIncTax')&.text).to eq income_tax.to_s # 17
        expect(xml.document.at('UseTax')&.text).to eq "100" # 18
        expect(xml.document.at('NoUseTaxDue')&.text).to eq nil # 18
        expect(xml.document.at('TotalNCTax')&.text).to eq "500" # 19
        expect(xml.document.at('IncTaxWith')&.text).to eq income_tax_withheld.to_s # 20a
        expect(xml.document.at('IncTaxWithSpouse')&.text).to eq income_tax_withheld_spouse.to_s # 20b
        expect(xml.document.at('NCTaxPaid')&.text).to eq tax_paid.to_s # 23
        expect(xml.document.at('RemainingPayment')&.text).to eq tax_paid.to_s # 23
        expect(xml.document.at('TaxDue')&.text).to eq nil # 26a
        expect(xml.document.at('TotalAmountDue')&.text).to eq "0" # 27
        expect(xml.document.at('Overpayment')&.text).to eq "2500" # 28
        expect(xml.document.at('RefundAmt')&.text).to eq "2500" # 34
        expect(xml.document.at('PaymentContact PersonName FirstName')&.text).to be_nil
        expect(xml.document.at('PaymentContact PersonName MiddleInitial')&.text).to be_nil
        expect(xml.document.at('PaymentContact PersonName LastName')&.text).to be_nil
        expect(xml.document.at('PaymentContact PersonName NameSuffix')).to be_nil
        expect(xml.document.at('PaymentContact USPhoneNumber')&.text).to be_nil
      end

      context "when owed" do
        let(:intake) { create(:state_file_nc_intake, :taxes_owed) }
        before do
          intake.phone_number = nil
        end

        it "should fill out taxes-owed related fields" do
          expect(xml.document.at('PaymentContact PersonName FirstName')&.text).to eq "North"
          expect(xml.document.at('PaymentContact PersonName MiddleInitial')&.text).to eq "A"
          expect(xml.document.at('PaymentContact PersonName LastName')&.text).to eq "Carolinian"
          expect(xml.document.at('PaymentContact PersonName NameSuffix')).to be_nil
          expect(xml.document.at('PaymentContact USPhoneNumber')&.text).to eq "9845559876"
        end

        context "if filer does have phone number collected at intake" do
          before do
            intake.phone_number = "9887779999"
          end
          it "fills the USPhoneNumber with more recent phone number collected at intake" do
            expect(xml.document.at('PaymentContact USPhoneNumber')&.text).to eq "9887779999"
          end
        end
      end

      it "correctly fills veteran info for primary" do
        intake.update(primary_veteran: "yes")
        expect(xml.document.at('VeteranInfoPrimary')&.text).to eq "1"
      end

      context "CTC-related values" do
        let(:intake) { create(:state_file_nc_intake, filing_status: "head_of_household", raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("nc_nala_hoh")) }
        let(:child_deduction) { 2000 }

        before do
          intake.direct_file_data.qualifying_children_under_age_ssn_count = 3
          allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_10b).and_return child_deduction
        end

        it "pulls from DF" do
          expect(xml.document.at('NumChildrenAllowed')&.text).to eq "3"
          expect(xml.document.at('ChildDeduction')&.text).to eq child_deduction.to_s
        end
      end
    end

    context "mfj filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_jointly") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('ResidencyStatusSpouse')&.text).to eq "true"
        expect(xml.document.at('FilingStatus')&.text).to eq "MFJ"
      end

      it "correctly fills veteran info for both primary and spouse" do
        intake.update(primary_veteran: "yes", spouse_veteran: "no")
        expect(xml.document.at('VeteranInfoPrimary')&.text).to eq "1"
        expect(xml.document.at('VeteranInfoSpouse')&.text).to eq "0"
      end
    end

    context "mfs filers" do
      let(:intake) { create(:state_file_nc_intake, :with_filers_synced, filing_status: "married_filing_separately") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('FilingStatus')&.text).to eq "MFS"
        expect(xml.document.at('MFSSpouseName FirstName')&.text).to eq "Susie"
        expect(xml.document.at('MFSSpouseName MiddleInitial')&.text).to eq "K"
        expect(xml.document.at('MFSSpouseName LastName')&.text).to eq "Cave"
        expect(xml.document.at('MFSSpouseSSN')&.text).to eq "600000030"
      end
    end

    context "hoh filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "head_of_household") }

      it "correctly fills head-of-household-specific answers" do
        expect(xml.document.at('FilingStatus')&.text).to eq "HOH"
      end
    end

    context "qw filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "qualifying_widow") }
      before do
        intake.direct_file_data.spouse_date_of_death = "#{Rails.configuration.statefile_current_tax_year}-09-30"
      end

      it "correctly fills qualifying-widow-specific answers" do
        expect(xml.document.at('FilingStatus')&.text).to eq "QW"
        expect(xml.document.at('QWYearSpouseDied')&.text).to eq Rails.configuration.statefile_current_tax_year.to_s
      end
    end
  end
end
