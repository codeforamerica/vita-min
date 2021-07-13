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
        expect {
          described_class.perform_now(submission.id)
        }.to change(submission.reload, :current_state).from("preparing").to("queued")
      end
    end

    context "when the build is not successful" do
      it "transitions the submission into :build_failed"
    end
  end
end