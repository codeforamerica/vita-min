require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Id::Documents::Id40, required_schema: "id" do
  describe ".document" do
    let(:intake) { create(:state_file_id_intake, filing_status: "single") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "correctly fills out the answers" do
      expect(xml.document.at('ResidencyStatusPrimary').text).to eq "true"
    end
  end
end