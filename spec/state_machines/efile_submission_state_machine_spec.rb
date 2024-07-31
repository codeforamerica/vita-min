require 'rails_helper'

describe EfileSubmissionStateMachine do
  before do
    allow(ClientPdfDocument).to receive(:create_or_update)
    allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    create :fraud_indicator
  end

  describe "after_transition" do
    context "to preparing" do
      let(:submission) { create(:efile_submission, :new, :for_state) }

      context "for state file submissions" do
        let(:messaging_service) { instance_double(StateFile::AfterTransitionMessagingService) }

        before do
          allow(StateFile::AfterTransitionMessagingService).to receive(:new).with(submission).and_return(messaging_service)
          allow(messaging_service).to receive(:send_efile_submission_successful_submission_message)
        end

        it "sends a successful submission message" do
          submission.transition_to!(:preparing)
          expect(messaging_service).to have_received(:send_efile_submission_successful_submission_message)
        end
      end
    end

    context "to bundling" do
      let!(:submission) { create(:efile_submission, :preparing, :for_state) }

      it "kicks off submission bundle building" do
        expect(StateFile::BuildSubmissionBundleJob).to receive(:perform_later).with(submission.id)

        submission.transition_to!(:bundling)
      end
    end

    context "to transmitted" do
      let(:submission) { create(:efile_submission, :queued, :for_state) }

      context "state file intakes" do
        before do
          submission.update(data_source: create(:state_file_az_intake))
        end

        it "updates state file analytics record with submission data" do
          submission.transition_to(:transmitted)

          expect(submission.data_source.state_file_analytics.fed_eitc_amount).to eq 1776
          expect(submission.data_source.state_file_analytics.filing_status).to eq 1
          expect(submission.data_source.state_file_analytics.refund_or_owed_amount).to eq -2011
        end
      end
    end

    context "to failed" do
      let(:submission) { create(:efile_submission, :queued, :for_state) }
      let!(:efile_error) { create(:efile_error, code: "USPS", expose: true, auto_wait: false, auto_cancel: false, service_type: :ctc) }

      context "schedule job for still processing notice" do
        context "for state filing" do
          it "enqueues StateFile::SendStillProcessingNoticeJob with run time at 24 hours from now" do
            fake_time = Time.now
            submission.update(data_source: create(:state_file_az_intake), tax_return: nil)
            Timecop.freeze(fake_time) do
              expect {
                submission.transition_to!(:failed)
              }.to have_enqueued_job(StateFile::SendStillProcessingNoticeJob).with(submission.reload)
              expect(DateTime.parse(ActiveJob::Base.queue_adapter.enqueued_jobs.last["scheduled_at"])).to eq fake_time + 24.hours
            end
          end
        end
      end
    end

    context "to rejected" do
      let(:submission) { create(:efile_submission, :transmitted) }
      let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: false, auto_cancel: false) }

      it "enqueues an StateFile::AfterTransitionTasksForRejectedReturnJob" do
        submission.transition_to!(:rejected, error_code: efile_error.code)

        expect(StateFile::AfterTransitionTasksForRejectedReturnJob).to have_been_enqueued.with(submission, submission.last_transition)
      end

      context "transition from failed" do
        let(:submission) { create(:efile_submission, :failed) }

        context "in prod" do
          before do
            allow(Rails.env).to receive(:production?).and_return(true)
          end

          it "raises an error" do
            expect { submission.transition_to!(:rejected) }.to raise_error(Statesman::GuardFailedError)
          end
        end

        context "in heroku" do
          before do
            allow(Rails.env).to receive(:heroku?).and_return(true)
          end

          it "succeeds in transitioning to rejected" do
            submission.transition_to!(:rejected)
            expect(submission.current_state).to eq "rejected"
          end
        end
      end

      context "schedule job for still processing notice" do
        context "for state filing" do
          it "enqueues StateFile::SendStillProcessingNoticeJob with run time at 24 hours from now" do
            fake_time = Time.now
            submission.update(data_source: create(:state_file_az_intake), tax_return: nil)
            Timecop.freeze(fake_time) do
              expect {
                submission.transition_to!(:failed)
              }.to have_enqueued_job(StateFile::SendStillProcessingNoticeJob).with(submission.reload)
              expect(DateTime.parse(ActiveJob::Base.queue_adapter.enqueued_jobs.last["scheduled_at"])).to eq fake_time + 24.hours
            end
          end
        end

        context "not for state filing" do
          it "does not enqueue StateFile::SendStillProcessingNoticeJob" do
            submission.transition_to!(:failed)
            expect(StateFile::SendStillProcessingNoticeJob).not_to have_been_enqueued.with(submission)
          end
        end
      end
    end

    context "to notified_of_rejection" do
      let!(:submission) { create(:efile_submission, :rejected, :for_state) }
      let!(:other_submisssion) { create(:efile_submission, :waiting, :for_state) }
      let(:after_transition_messaging_service) { StateFile::AfterTransitionMessagingService.new(submission)}

      before do
        allow(StateFile::AfterTransitionMessagingService).to receive(:new).with(submission).and_return(after_transition_messaging_service)
        allow(after_transition_messaging_service).to receive(:send_efile_submission_rejected_message)
      end

      context "currently in rejected state" do
        it "enqueues an StateFile::AfterTransitionTasksForRejectedReturnJob" do
          submission.transition_to!(:notified_of_rejection)
          expect(StateFile::AfterTransitionMessagingService).to have_received(:new).with(submission)
        end
      end

      context "currently in waiting state" do
        let!(:submission) { create(:efile_submission, :waiting, :for_state) }

        it "enqueues an StateFile::AfterTransitionTasksForRejectedReturnJob" do
          submission.transition_to!(:notified_of_rejection)
          expect(StateFile::AfterTransitionMessagingService).to have_received(:new).with(submission)
        end
      end
    end

    context "to accepted" do
      let(:submission) { create(:efile_submission, :transmitted, :for_state) }
      let(:messaging_service) { instance_double(StateFile::AfterTransitionMessagingService) }
      before do
        allow(StateFile::AfterTransitionMessagingService).to receive(:new).and_return(messaging_service)
      end

      it "sends a message to the client" do
        expect(messaging_service).to receive(:send_efile_submission_accepted_message)
        submission.transition_to!(:accepted)
      end
    end

    context "to resubmitted" do
      let!(:efile_submission) { create :efile_submission, :transmitted, :for_state }

      before do
        efile_submission.transition_to!(:rejected)
      end

      it "creates a new efile submission" do
        expect {
          efile_submission.transition_to!(:resubmitted)
        }.to change(EfileSubmission, :count).by 1
        expect(efile_submission.current_state).to eq "resubmitted"
        new_submission = EfileSubmission.last
        expect(new_submission.current_state).to eq "bundling"
        expect(new_submission.last_transition_to("preparing").metadata["previous_submission_id"]).to eq efile_submission.id
      end
    end
  end
end
