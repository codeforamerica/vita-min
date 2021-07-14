require "rails_helper"

describe BuildSubmissionBundleJob do
  describe '.perform' do
    let(:submission) { create :efile_submission, :preparing, :ctc }
    context "when the build is successful" do
      before do
        allow(SubmissionBundle).to receive(:build).and_return SubmissionBundleResponse.new
        allow_any_instance_of(EfileSubmission).to receive(:submission_bundle).and_return "yes"
      end

      it "transitions the submission into :queued" do
        described_class.perform_now(submission.id)
        expect(submission.reload.current_state).to eq "queued"
      end
    end

    context "when the build is not successful" do
      before do
        allow(SubmissionBundle).to receive(:build).and_return SubmissionBundleResponse.new(errors: ["error"])
      end
      it "transitions the submission into :build_failed" do
        described_class.perform_now(submission.id)
        expect(submission.reload.current_state).to eq "bundle_failure"
      end
    end
  end
end