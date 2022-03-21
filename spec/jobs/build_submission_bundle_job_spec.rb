require "rails_helper"

describe BuildSubmissionBundleJob do
  describe '.perform' do
    let(:submission) { create :efile_submission, :preparing, :ctc }
    let(:address_valid?) { true }
    let(:address_errors) { "" }

    before do
      address_service_double = instance_double(StandardizeAddressService, valid?: address_valid?, error_message: address_errors, error_code: address_errors)
      allow_any_instance_of(EfileSubmission).to receive(:generate_irs_address).and_return(address_service_double)
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

    context "when there is an error creating the irs 1040 pdf" do
      before do
        allow_any_instance_of(EfileSubmission).to receive(:generate_form_1040_pdf).and_raise StandardError
      end

      it "transitions the submission into :failed" do
        expect do
          described_class.perform_now(submission.id)
        end.to raise_error(StandardError)
        expect(submission.reload.current_state).to eq "failed"
        expect(submission.efile_submission_transitions.last.efile_errors.length).to eq 1
        expect(submission.efile_submission_transitions.last.efile_errors.first.message).to eq "Could not generate IRS Form 1040 PDF."
        expect(submission.efile_submission_transitions.last.efile_errors.first.code).to eq "PDF-1040-FAIL"

        expect(submission.efile_submission_transitions.last.metadata['error_code']).to eq "PDF-1040-FAIL"
      end
    end

    context "EfileSubmissionDependent creation" do
      before do
        allow(SubmissionBundle).to receive(:build).and_return SubmissionBundleResponse.new
        allow_any_instance_of(EfileSubmission).to receive(:submission_bundle).and_return "yes"
        submission.intake.dependents.delete_all
        create :qualifying_child, intake: submission.intake # creates object
        create :qualifying_relative, intake: submission.intake # creates object
        create :dependent, intake: submission.intake # does not qualify, does not create object
      end

      it "creates EfileSubmissionDependent objects for each qualifying dependent" do
        expect(submission.intake.dependents.length).to eq 3
        expect {
          described_class.perform_now(submission.id)
        }.to change(EfileSubmissionDependent, :count).by 2
      end

      context "when objects already exist for some dependents" do
        before do
          EfileSubmissionDependent.create(dependent: submission.intake.dependents.first, efile_submission: submission)
        end

        it "does not create duplicated objects" do
          expect(submission.intake.dependents.length).to eq 3
          expect(EfileSubmissionDependent.where(efile_submission: submission).count).to eq 1
          described_class.perform_now(submission.id)
          expect(EfileSubmissionDependent.count).to eq 2 # there is still only one entry for each qualifying dependent
        end
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
