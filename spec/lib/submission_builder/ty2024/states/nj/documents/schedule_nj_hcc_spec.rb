require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::ScheduleNjHcc, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    after do
      expect(build_response.errors).not_to be_present
    end

    it "checks HealthCovAllYear" do
      expect(xml.at("HealthCovAllYear").text).to eq("X")
    end
  end
end