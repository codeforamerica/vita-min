require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nc::NcReturnXml, required_schema: "nc" do
  describe '.build' do
    let(:intake) { create(:state_file_nc_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:build_response) { described_class.build(submission) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
    end

    # the single filer block tests all answers that are not specific to filing status
    # the other blocks test only what is specific to that filing status
    context "single filer" do
      before do
        intake.direct_file_data.fed_agi = 10000
      end

      it "correctly fills answers" do
        expect(xml.document.at('ResidencyStatusPrimary').text).to eq "true"
        expect(xml.document.at('ResidencyStatusSpouse')).to be_nil
        expect(xml.document.at('FilingStatus').text).to eq "Single"
        expect(xml.document.at('FAGI').text).to eq "10000"
        expect(xml.document.at('NCStandardDeduction').text).to eq "12750"
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