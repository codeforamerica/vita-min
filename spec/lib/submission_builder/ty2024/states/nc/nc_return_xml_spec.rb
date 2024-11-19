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
      expect(xml.css("FormNCD400ScheduleS").count).to eq 0
      expect(build_response.errors).not_to be_present
    end

    context "with DeductionsFromFAGI" do
      before do
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:calculate_line_9).and_return 5
      end

      it "includes NC D400 Schedule S Form" do
        expect(xml.css("FormNCD400ScheduleS").count).to eq 1
      end
    end

    context "when there is a refund with banking info" do
      let(:intake) { create(:state_file_nc_refund_intake) }

      it "generates FinancialTransaction xml with correct RefundAmt" do
        allow_any_instance_of(Efile::Nc::D400Calculator).to receive(:refund_or_owed_amount).and_return 500
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("RefundDirectDeposit Amount").text).to eq "500"
      end
    end
  end
end
