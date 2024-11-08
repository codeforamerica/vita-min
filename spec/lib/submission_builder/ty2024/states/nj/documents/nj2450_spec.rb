require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: true) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "xyz" do
      # expect(xml.document.at("CountyCode").to_s).to include("00101")
    end
  end
end