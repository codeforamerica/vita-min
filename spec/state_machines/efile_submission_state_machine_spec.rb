require 'rails_helper'

describe EfileSubmissionStateMachine do
  before do
    allow(ClientPdfDocument).to receive(:create_or_update)
  end

  describe "after_transition" do
    context "to preparing" do
      let(:submission) { create(:efile_submission, :new) }

      context "without blocking fraud characteristics" do
        it "enqueues a BuildSubmissionBundleJob" do
          expect {
            submission.transition_to!(:preparing)
          }.to have_enqueued_job(BuildSubmissionBundleJob)
        end

        it "updates the tax return status" do
          submission.transition_to!(:preparing)
          expect(submission.tax_return.status).to eq("file_ready_to_file")
        end
      end

      context "with blocking fraud characteristics" do
        before do
          submission.client.efile_security_informations.last.update(recaptcha_score: 0.3)
        end

        it "does not enqueue a job" do
          expect {
            submission.transition_to!(:preparing)
          }.not_to have_enqueued_job(BuildSubmissionBundleJob)
        end

        it "transitions the tax return status and submission status to hold" do
          submission.transition_to!(:preparing)
          expect(submission.current_state).to eq "fraud_hold"
          expect(submission.tax_return.status).to eq("file_hold")
        end
      end


      context "from new to preparing" do
        before do
          allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
        end
        context "when this is the first submission" do
          it "sends a message to the client" do
            submission.transition_to!(:preparing)

            expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
                client: submission.client.reload,
                message: instance_of(AutomatedMessage::EfilePreparing),
                locale: submission.client.intake.locale
            )
          end

        end

        context "when there is a previous submission" do
          before do
            create(:efile_submission, tax_return: submission.tax_return)
          end
          it "does not send a message to the client" do
            submission.transition_to!(:preparing)
            expect(ClientMessagingService).not_to have_received(:send_system_message_to_all_opted_in_contact_methods)
          end
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
      let(:efile_error) { create(:efile_error, code: "USPS", expose: true, auto_wait: false, auto_cancel: false) }

      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      end

      it "updates the tax return status" do
        submission.transition_to!(:failed, error_code: efile_error.code)
        expect(submission.tax_return.status).to eq("file_needs_review")
      end

      context "with an exposed error" do
        it "sends the client a message" do
          submission.transition_to!(:failed, error_code: efile_error.code)
          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: submission.client.reload,
            message: instance_of(AutomatedMessage::EfileFailed),
            locale: submission.client.intake.locale
          )
        end
      end

      context "without an exposed error" do
        let(:efile_error) { create(:efile_error, code: "USPS", expose: false) }

        it "does not send a message" do
          submission.transition_to!(:failed)
          expect(ClientMessagingService).not_to have_received(:send_system_message_to_all_opted_in_contact_methods)
        end
      end
    end

    context "to rejected" do
      let(:submission) { create(:efile_submission, :transmitted) }
      let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: false, auto_cancel: false) }

      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      end

      it "updates the tax return status" do
        submission.transition_to!(:rejected, error_code: efile_error.code)
        expect(submission.tax_return.status).to eq("file_rejected")
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: submission.client.reload,
          message: instance_of(AutomatedMessage::EfileRejected),
          locale: submission.client.intake.locale
        )
      end
    end

    context "to investigating" do
      let(:submission) { create(:efile_submission, :rejected) }
      it "transitions the tax return status to on hold" do
        expect {
          submission.transition_to!(:investigating)
        }.to change(submission.tax_return, :status).to("file_hold")
      end
    end

    context "to waiting" do
      let(:submission) { create(:efile_submission, :rejected) }
      it "transitions the tax return status to on hold" do
        expect {
          submission.transition_to!(:waiting)
        }.to change(submission.tax_return, :status).to("file_hold")
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
          new_submission = EfileSubmission.last
          expect(new_submission.current_state).to eq "preparing"
          expect(new_submission.last_transition.metadata["previous_submission_id"]).to eq efile_submission.id
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
