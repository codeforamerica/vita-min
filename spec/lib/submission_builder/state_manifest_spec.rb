require "rails_helper"

describe SubmissionBuilder::StateManifest do
  describe ".build" do
    let(:intake) { create :state_file_az_intake }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:doc) { described_class.new(submission).document }

    context "single filer" do
      it "has some of the right values" do
        expect(doc.at("StateSubmissionTyp").text).to eq "Form140"
        expect(doc.at("SpouseNameControlTxt")).to be_nil
        expect(doc.at("SpouseSSN")).to be_nil
      end
    end

    context "married filing jointly" do
      let(:intake) { create :state_file_az_intake, :with_spouse, :with_filers_synced }

      it "should fill out the spouse fields" do
        expect(doc.at("SpouseNameControlTxt").text).to eq "OHAR"
        expect(doc.at("SpouseSSN").text).to eq "600000001"
      end
    end
  end
end
