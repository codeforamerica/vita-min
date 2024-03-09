require "rails_helper"

describe AfterTransitionTasksForRejectedReturnJob do
  describe '.perform' do
    let(:submission) { create(:efile_submission, :transmitted, :ctc) }
    let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: auto_wait, auto_cancel: auto_cancel, service_type: :ctc) }
    let(:auto_wait) { false }
    let(:auto_cancel) { false }

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      submission.transition_to!(:rejected, error_code: efile_error.code)
    end

    it "updates the tax return status and sends a message" do
      AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

      expect(submission.tax_return.reload.current_state).to eq("file_rejected")
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

        expect(submission.tax_return.reload.current_state).to eq("file_hold")
        expect(submission.current_state).to eq("waiting")
      end
    end

    context "when the error is auto-cancel" do
      let(:auto_cancel) { true }
      it "updates the tax status and submission status and uses custom rejection message" do
        AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

        expect(submission.tax_return.reload.current_state).to eq("file_not_filing")
        expect(submission.current_state).to eq("cancelled")
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).once.with(
          client: submission.client.reload,
          message: AutomatedMessage::EfileRejectedAndCancelled,
          locale: submission.client.intake.locale
        )
      end
    end

    context "when the error is auto-resubmit" do
      before do
        allow(EfileError).to receive(:error_codes_to_retry_once).and_return([efile_error.code])
      end

      it "transitions to resubmitted exactly once" do
        AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)

        expect(EfileSubmission.count).to eq(2)
        expect(submission.current_state).to eq("resubmitted")

        resubmission = EfileSubmission.last
        resubmission.transition_to!(:queued)
        resubmission.transition_to!(:transmitted)
        resubmission.transition_to!(:rejected, error_code: efile_error.code)
        expect(resubmission.current_state).to eq("rejected")
      end
    end

    context "schedule job for still processing notice" do
      context "for state filing" do
        it "enqueues StateFile::SendStillProcessingNoticeJob with run time at 24 hours from now" do
          fake_time = Time.now
          submission.update(data_source: create(:state_file_az_intake), tax_return: nil)
          Timecop.freeze(fake_time) do
            expect {
              AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)
            }.to have_enqueued_job(StateFile::SendStillProcessingNoticeJob).with(submission.reload, run_at: fake_time + 24.hours)
          end
        end
      end

      context "not for state filing" do
        it "does not enqueue StateFile::SendStillProcessingNoticeJob" do
          AfterTransitionTasksForRejectedReturnJob.perform_now(submission, submission.last_transition)
          expect(StateFile::SendStillProcessingNoticeJob).not_to have_been_enqueued.with(submission)
        end
      end
    end
  end

  describe '#job_object_id' do
    let(:submission) { create(:efile_submission, :transmitted) }
    let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: false, auto_cancel: false) }

    before do
      submission.transition_to!(:rejected, error_code: efile_error.code)
    end

    it 'returns the id of the EfileSubmission record' do
      job = described_class.perform_later(submission, submission.last_transition)
      expect(job.job_object_id).to eq(submission.id)
    end
  end
end
