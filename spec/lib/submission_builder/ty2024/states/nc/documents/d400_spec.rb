require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nc::Documents::D400, required_schema: "nc" do
  describe ".document" do
    let(:intake) { create(:state_file_nc_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    # the single filer block tests all answers that are not specific to filing status
    # the other blocks test only what is specific to that filing status
    context "single filer" do
      let(:income_tax_withheld) { 2000 }
      let(:income_tax_withheld_spouse) { 1000 }
      let(:tax_paid) { 3000 }
      let(:standard_deduction) { 12750 }
      let(:nc_agi_addition) { 18750 }
      before do
        intake.direct_file_data.fed_agi = 10000
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_11).and_return standard_deduction
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_12a).and_return nc_agi_addition
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20a).and_return income_tax_withheld
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20b).and_return income_tax_withheld_spouse
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_23).and_return tax_paid
      end

      it "correctly fills answers" do
        expect(xml.document.at('ResidencyStatusPrimary').text).to eq "true"
        expect(xml.document.at('ResidencyStatusSpouse')).to be_nil
        expect(xml.document.at('VeteranInfoSpouse')).to be_nil
        expect(xml.document.at('FilingStatus').text).to eq "Single"
        expect(xml.document.at('FAGI').text).to eq "10000"
        expect(xml.document.at('FAGIPlusAdditions').text).to eq "10000"
        expect(xml.document.at('NCStandardDeduction').text).to eq standard_deduction.to_s
        expect(xml.document.at('NCAGIAddition').text).to eq nc_agi_addition.to_s
        expect(xml.document.at('IncTaxWith').text).to eq income_tax_withheld.to_s
        expect(xml.document.at('IncTaxWithSpouse').text).to eq income_tax_withheld_spouse.to_s
        expect(xml.document.at('NCTaxPaid').text).to eq tax_paid.to_s
        expect(xml.document.at('RemainingPayment').text).to eq tax_paid.to_s
        expect(xml.document.at('NCCountyCode').text).to eq "001"
      end

      it "correctly fills veteran info for primary" do
        intake.update(primary_veteran: "yes")
        expect(xml.document.at('VeteranInfoPrimary').text).to eq "1"
      end

      context "CTC-related values" do
        let(:intake) { create(:state_file_nc_intake, filing_status: "head_of_household", raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("nc_shiloh_hoh")) }
        let(:child_deduction) { 2000 }

        before do
          intake.direct_file_data.qualifying_children_under_age_ssn_count = 3
          allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_10b).and_return child_deduction
        end

        it "pulls from DF" do
          expect(xml.document.at('NumChildrenAllowed').text).to eq "3"
          expect(xml.document.at('ChildDeduction').text).to eq child_deduction.to_s
        end
      end
    end

    context "mfj filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_jointly") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('ResidencyStatusSpouse').text).to eq "true"
        expect(xml.document.at('FilingStatus').text).to eq "MFJ"
      end

      it "correctly fills veteran info for both primary and spouse" do
        intake.update(primary_veteran: "yes", spouse_veteran: "no")
        expect(xml.document.at('VeteranInfoPrimary').text).to eq "1"
        expect(xml.document.at('VeteranInfoSpouse').text).to eq "0"
      end
    end

    context "mfs filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_separately") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('FilingStatus').text).to eq "MFS"
        expect(xml.document.at('MFSSpouseName').text).to eq "Sophie Cave"
        expect(xml.document.at('MFSSpouseSSN').text).to eq "600000030"
      end
    end

    context "hoh filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "head_of_household") }

      it "correctly fills head-of-household-specific answers" do
        expect(xml.document.at('FilingStatus').text).to eq "HOH"
      end
    end

    context "qw filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "qualifying_widow") }
      before do
        intake.direct_file_data.spouse_date_of_death = "2023-09-30"
      end

      it "correctly fills qualifying-widow-specific answers" do
        expect(xml.document.at('FilingStatus').text).to eq "QW"
        expect(xml.document.at('QWYearSpouseDied').text).to eq "2023"
      end
    end
  end
end
