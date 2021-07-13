require "rails_helper"

describe SubmissionBundle do
  let(:submission) { create :efile_submission, :ctc }

  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efin).and_return "123456"
  end

  describe "#build" do
    it "stores the submission bundle on the submission" do
      response = described_class.new(submission, documents: ["adv_ctc_irs1040"]).build

      expect(submission.reload.submission_bundle).to be_present
      expect(submission.submission_bundle.content_type).to eq "application/zip"
      file_name = ActiveStorage::Blob.service.path_for(submission.submission_bundle.key)
      Zip::File.open_buffer(File.open(file_name, "rb")) do |zip_file|
        expect(zip_file.entries.first.name).to eq "manifest/manifest.xml"
        expect(zip_file.entries.last.name).to eq "xml/submission.xml"
      end
      expect(response).to be_valid
    end

    context "when a SubmissionBuilder instance is not valid" do
      let(:submission_builder_double) { double(SubmissionBuilder::Response) }
      let(:errors) { ['error', 'error'] }
      before do
        allow(SubmissionBuilder::Manifest).to receive(:build).and_return SubmissionBuilder::Response.new(errors: errors, document: nil, root_node: nil )
      end

      it "returns errors from the SubmissionBuilder::Response" do
        expect(described_class.new(submission, documents: ["adv_ctc_irs1040"]).build.errors).to eq ['error', 'error']
      end
    end
  end
end