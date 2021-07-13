require "rails_helper"

describe SubmissionBundle do
  let(:submission) { create :efile_submission, :ctc }
  describe "#build" do
    it "stores the submission bundle on the submission" do
      described_class.new(submission, documents: ["adv_ctc_irs1040"]).build
      expect(submission.reload.submission_bundle).to be_present
      expect(submission.submission_bundle.content_type).to eq "application/zip"
      file_name = ActiveStorage::Blob.service.path_for(submission.submission_bundle.key)
      Zip::File.open_buffer(File.open(file_name, "rb")) do |zip_file|
        expect(zip_file.entries.first.name).to eq "manifest/manifest.xml"
        expect(zip_file.entries.last.name).to eq "xml/submission.xml"
      end
    end
  end
end