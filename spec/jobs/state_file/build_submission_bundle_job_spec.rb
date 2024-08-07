require "rails_helper"

describe StateFile::BuildSubmissionBundleJob do
  describe '.perform' do
    let(:submission) { create :efile_submission, :bundling, :for_state }
    let(:address_valid?) { true }
    let(:address_errors) { "" }

    before do
      address_service_double = instance_double(StandardizeAddressService, valid?: address_valid?, error_message: address_errors, error_code: address_errors)
      allow_any_instance_of(EfileSubmission).to receive(:generate_verified_address).and_return(address_service_double)
      DefaultErrorMessages.generate!
    end

    context "when the address did not validate" do
      let(:address_valid?) { false }
      let(:address_errors) { "usps error your zip code is a duck" }

      it "transitions the submission into :failed" do
        described_class.perform_now(submission.id)
        expect(submission.reload.current_state).to eq "failed"
        expect(submission.efile_submission_transitions.last.metadata['error_message']).to eq address_errors
      end
    end

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

      it "transitions the submission into :failed" do
        described_class.perform_now(submission.id)
        expect(submission.reload.current_state).to eq "failed"
      end
    end

    context "when the build raises an unhandled exception" do
      before do
        allow(SubmissionBundle).to receive(:build).and_raise StandardError
      end

      it "transitions the submission into :failed" do
        expect do
          described_class.perform_now(submission.id)
        end.to raise_error(StandardError)
        expect(submission.reload.current_state).to eq "failed"
      end
    end
  end
end
