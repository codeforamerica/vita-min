require "rails_helper"

describe SubmissionBuilder::StateManifest do
  describe ".build" do
    let(:intake) { create :state_file_az_intake }
    let(:submission) { create(:efile_submission, data_source: intake) }

    it "has some of the right values" do
      doc = described_class.new(submission).document
      expect(doc.at("StateSubmissionTyp").text).to eq "Form140"
    end
  end
end
