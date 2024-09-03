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
      before do
        intake.direct_file_data.fed_agi = 10000
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20a).and_return income_tax_withheld
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_20b).and_return income_tax_withheld_spouse
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_23).and_return tax_paid
      end

      it "correctly fills answers" do
        expect(xml.document.at('ResidencyStatusPrimary').text).to eq "true"
        expect(xml.document.at('ResidencyStatusSpouse')).to be_nil
        expect(xml.document.at('FilingStatus').text).to eq "Single"
        expect(xml.document.at('FAGI').text).to eq "10000"
        expect(xml.document.at('FAGIPlusAdditions').text).to eq "10000"
        expect(xml.document.at('NCStandardDeduction').text).to eq "12750"
        # 12a = (11)NCStandardDeduction + (10b)ChildDeduction expect(xml.document.at('NCAGIAddition').text).to eq ""
        expect(xml.document.at('IncTaxWith').text).to eq income_tax_withheld.to_s
        expect(xml.document.at('IncTaxWithSpouse').text).to eq income_tax_withheld_spouse.to_s
        expect(xml.document.at('NCTaxPaid').text).to eq tax_paid.to_s
      end
    end

    context "mfj filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_jointly") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('ResidencyStatusSpouse').text).to eq "true"
        expect(xml.document.at('FilingStatus').text).to eq "MFJ"
        expect(xml.document.at('NCStandardDeduction').text).to eq "25500"
      end
    end

    context "mfs filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "married_filing_separately") }

      it "correctly fills spouse-specific answers" do
        expect(xml.document.at('FilingStatus').text).to eq "MFS"
        expect(xml.document.at('MFSSpouseName').text).to eq "Sophie Cave"
        expect(xml.document.at('MFSSpouseSSN').text).to eq "600000030"
        expect(xml.document.at('NCStandardDeduction').text).to eq "12750"
      end
    end

    context "hoh filers" do
      let(:intake) { create(:state_file_nc_intake, filing_status: "head_of_household") }

      it "correctly fills head-of-household-specific answers" do
        expect(xml.document.at('FilingStatus').text).to eq "HOH"
        expect(xml.document.at('NCStandardDeduction').text).to eq "19125"
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
        expect(xml.document.at('NCStandardDeduction').text).to eq "25500"
      end
    end
  end
end