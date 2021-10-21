require "rails_helper"

describe AfterTransitionTasksForRejectedReturnJob do
  describe '.perform' do
    let(:submission) { create(:efile_submission, :transmitted) }
    let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: auto_wait, auto_cancel: auto_cancel) }
    let(:auto_wait) { false }
    let(:auto_cancel) { false }

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      submission.transition_to!(:rejected, error_code: efile_error.code)
    end

    it "updates the tax return status and sends a message" do
      AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

      expect(submission.tax_return.reload.status).to eq("file_rejected")
      expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
        client: submission.client.reload,
        message: AutomatedMessage::EfileRejected,
        locale: submission.client.intake.locale
      )
    end

    context "when the error is auto-wait" do
      let(:auto_wait) { true }
      it "updates the tax status and submission status" do
        AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

        expect(submission.tax_return.reload.status).to eq("file_hold")
        expect(submission.current_state).to eq("waiting")
      end
    end


    context "when the error is auto-cancel" do
      let(:auto_cancel) { true }
      it "updates the tax status and submission status" do
        AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

        expect(submission.tax_return.reload.status).to eq("file_not_filing")
        expect(submission.current_state).to eq("cancelled")
      end
    end
  end
end
