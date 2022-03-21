require 'rails_helper'

describe EfileSubmissionStateMachine do
  before do
    allow(ClientPdfDocument).to receive(:create_or_update)
    allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
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
          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: submission.client.reload,
            message: AutomatedMessage::EfilePreparing,
          )
        end
      end

      context "when the client has had their identity verified" do
        before do
          submission.client.touch(:identity_verified_at)
          allow(FraudIndicatorService).to receive(:hold_indicators)
        end

        it "does not check for fraud indicators" do
          submission.transition_to!(:preparing)
          expect(FraudIndicatorService).not_to have_received(:hold_indicators)
        end

        it "allows transition" do
          submission.transition_to!(:preparing)
          expect(submission.tax_return.status).to eq("file_ready_to_file")
        end
      end

      context "with blocking fraud characteristics" do
        before do
          submission.client.efile_security_informations.last.update(timezone: "Western Europe")
        end

        it "does not enqueue a job" do
          expect {
            submission.transition_to!(:preparing)
          }.not_to have_enqueued_job(BuildSubmissionBundleJob)
        end

        it "transitions the tax return status and submission status to hold" do
          submission.transition_to!(:preparing)
          expect(submission.current_state).to eq "fraud_hold"
          expect(submission.last_transition.metadata["indicators"]).to eq ["international_timezone"]
          expect(submission.tax_return.status).to eq("file_fraud_hold")
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
            message: AutomatedMessage::EfileFailed,
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

      it "enqueues an AfterTransitionTasksForRejectedReturnJob" do
        submission.transition_to!(:rejected, error_code: efile_error.code)

        expect(AfterTransitionTasksForRejectedReturnJob).to have_been_enqueued.with(submission, submission.last_transition)
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
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(1000)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1300)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)

        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:ctc_amount).and_return(2400)
      end

      it "sends a message to the client" do
        submission.transition_to!(:accepted)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: submission.client.reload,
          message: AutomatedMessage::EfileAcceptance,
          locale: submission.client.intake.locale
        )
      end

      it "updates the tax return status" do
        submission.transition_to!(:accepted)
        expect(submission.tax_return.status).to eq("file_accepted")
      end



      it "creates a record to store the tax return data" do
        expect {
          submission.transition_to(:accepted)
        }.to change(AcceptedTaxReturnAnalytics, :count).by 1
        expect(submission.tax_return.accepted_tax_return_analytics.advance_ctc_amount_cents).to eq 120000
        expect(submission.tax_return.accepted_tax_return_analytics.refund_amount_cents).to eq 230000
        expect(submission.tax_return.accepted_tax_return_analytics.eip3_amount_cents).to eq 240000
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
