require "rails_helper"

describe BuildSubmissionBundleJob do
  describe '.perform' do
    let(:submission) { create :efile_submission, :preparing, :ctc }
    let(:address_valid?) { true }
    let(:address_errors) { "" }

    before do
      address_service_double = instance_double(StandardizeAddressService, valid?: address_valid?, errors: address_errors)
      allow_any_instance_of(EfileSubmission).to receive(:generate_irs_address).and_return(address_service_double)
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

    context "when there is an error creating the irs 1040 pdf" do
      before do
        allow_any_instance_of(EfileSubmission).to receive(:generate_form_1040_pdf).and_raise StandardError
      end

      it "transitions the submission into :failed" do
        expect do
          described_class.perform_now(submission.id)
        end.to raise_error(StandardError)
        expect(submission.reload.current_state).to eq "failed"
        expect(submission.efile_submission_transitions.last.metadata['error_message']).to eq "Could not generate PDF Form 1040."
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
  end
end
