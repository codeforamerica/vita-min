require 'rails_helper'

describe EfileSubmissionStateMachine do

  before do
    allow(ClientPdfDocument).to receive(:create_or_update)
  end

  describe "after_transition" do
    context "to preparing" do
      let(:submission) { create(:efile_submission, :new) }

      it "enqueues a BuildSubmissionBundleJob" do
        expect {
          submission.transition_to!(:preparing)
        }.to have_enqueued_job(BuildSubmissionBundleJob)
      end

      it "updates the tax return status" do
        submission.transition_to!(:preparing)
        expect(submission.tax_return.status).to eq("file_ready_to_file")
      end

      context "from new to preparing" do
        before do
          allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
        end

        it "sends a message to the client" do
          submission.transition_to!(:preparing)

          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: submission.client.reload,
            message: instance_of(AutomatedMessage::EfilePreparing),
            locale: submission.client.intake.locale
          )
        end
      end
    end

    context "to transmitted" do
      let(:submission) { create(:efile_submission, :queued) }

      it "updates the tax return status" do
        submission.transition_to!(:transmitted)
        expect(submission.tax_return.status).to eq("file_efiled")
      end
    end

    context "to failed" do
      let(:submission) { create(:efile_submission, :queued) }

      it "updates the tax return status" do
        submission.transition_to!(:failed)
        expect(submission.tax_return.status).to eq("file_needs_review")
      end
    end

    context "to rejected" do
      let(:submission) { create(:efile_submission, :transmitted) }

      it "updates the tax return status" do
        submission.transition_to!(:rejected)
        expect(submission.tax_return.status).to eq("file_rejected")
      end
    end

    context "to accepted" do
      let(:submission) { create(:efile_submission, :transmitted) }

      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      end

      it "sends a message to the client" do
        submission.transition_to!(:accepted)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: submission.client.reload,
          message: instance_of(AutomatedMessage::EfileAcceptance),
          locale: submission.client.intake.locale
        )
      end

      it "updates the tax return status" do
        submission.transition_to!(:accepted)
        expect(submission.tax_return.status).to eq("file_accepted")
      end
    end

    context "to resubmitted" do
      context "when the submission has been transmitted to the IRS" do
        let!(:efile_submission) { create :efile_submission, :transmitted }

        before do
          efile_submission.transition_to!(:rejected)
        end

        it "creates a new efile submission" do
          expect {
            efile_submission.transition_to!(:resubmitted)
          }.to change(EfileSubmission, :count).by 1
          expect(efile_submission.current_state).to eq "resubmitted"
          expect(EfileSubmission.last.current_state).to eq "preparing"
          expect(EfileSubmission.last.last_transition.metadata["previous_submission_id"]).to eq efile_submission.id
        end
      end

      context "when the submission has never been transmitted to the IRS" do
        let!(:efile_submission) { create :efile_submission, :rejected }
        it "transitions the same submission back to preparing" do
          expect {
            efile_submission.transition_to!(:resubmitted)
          }.to change(EfileSubmission, :count).by 0
          expect(efile_submission.current_state).to eq "preparing"
        end
      end
    end
  end
end