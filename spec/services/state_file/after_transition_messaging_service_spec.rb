require "rails_helper"

describe StateFile::AfterTransitionMessagingService do
  let(:intake) { create :state_file_az_intake, primary_first_name: "Mona", email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, message_tracker: {} }
  let(:efile_submission) { create :efile_submission, :for_state, data_source: intake }
  let!(:messaging_service) { described_class.new(efile_submission) }
  let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/az/questions/return-status" } }
  let(:message) { StateFile::AutomatedMessage::AcceptedRefund }
  let(:sf_messaging_service) { StateFile::MessagingService.new(intake: intake, submission: efile_submission, message: message, body_args: body_args) }

  before do
    allow(StateFile::MessagingService).to receive(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args).and_return(sf_messaging_service)
    allow(StateFile::MessagingService).to receive(:new).with(intake: intake, submission: efile_submission, message: message).and_return(sf_messaging_service)
  end

  describe "#send_efile_submission_accepted_message" do
    before do
      allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(100)
    end

    context "when has a refund" do
      it "sends the accepted refund email message" do
        expect do
          messaging_service.send_efile_submission_accepted_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(efile_submission.message_tracker).to include "messages.state_file.accepted_refund"

        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args)
      end
    end

    context "when refund amount is zero" do
      before do
        allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(0)
      end

      it "sends the accepted refund email message" do
        expect do
          messaging_service.send_efile_submission_accepted_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(efile_submission.message_tracker).to include "messages.state_file.accepted_refund"

        expect(StateFile::MessagingService).to have_received(:new).with(
          intake: intake,
          submission: efile_submission,
          message: message,
          body_args: body_args
        )
      end
    end

    context "when owes taxes" do
      let(:message) { StateFile::AutomatedMessage::AcceptedOwe }
      let(:body_args) do
        {
          return_status_link: "http://statefile.test.localhost/en/az/questions/return-status",
          state_pay_taxes_link: "https://www.aztaxes.gov/"
        }
      end

      before do
        allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(-100)
      end

      it "sends the accepted owe email message" do
        expect do
          messaging_service.send_efile_submission_accepted_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(efile_submission.message_tracker).to include "messages.state_file.accepted_owe"

        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args)
      end
    end
  end

  describe '#schedule_survey_notification_job' do
    it 'enqueues SendSurveyNotificationJob' do
      # Freeze time
      frozen_time = Time.now
      Timecop.freeze(frozen_time)

      expect(SendSurveyNotificationJob).to receive(:set).with(wait_until: (frozen_time + 23.hours)).and_return(SendSurveyNotificationJob)
      expect(SendSurveyNotificationJob).to receive(:perform_later).with(intake, efile_submission)

      messaging_service.schedule_survey_notification_job

      # Unfreeze time
      Timecop.return
    end
  end

  describe "#send_efile_submission_rejected_message" do
    let(:message) { StateFile::AutomatedMessage::Rejected }

    it "sends the accepted refund" do
      expect do
        messaging_service.send_efile_submission_rejected_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(efile_submission.message_tracker).to include "messages.state_file.rejected"
      expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args)
    end
  end

  describe "#send_efile_submission_still_processing_message" do
    let(:message) { StateFile::AutomatedMessage::StillProcessing }

    it "sends the accepted refund" do
      expect do
        messaging_service.send_efile_submission_still_processing_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(efile_submission.message_tracker).to include "messages.state_file.still_processing"
      expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message)
    end
  end

  describe "#send_efile_submission_successful_submission_message" do
    let(:message) { StateFile::AutomatedMessage::SuccessfulSubmission }

    context "intake has only one submission" do
      let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/az/questions/return-status", submitted_or_resubmitted: "submitted"} }

      it "sends the successful submission message" do
        expect do
          messaging_service.send_efile_submission_successful_submission_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(efile_submission.message_tracker).to include "messages.state_file.successful_submission"
        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args)
      end
    end

    context "intake has more than one submission" do
      let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/az/questions/return-status", submitted_or_resubmitted: "resubmitted"} }
      let!(:second_efile_submission) { create :efile_submission, :for_state, data_source: intake }

      it "sends the successful submission message" do
        expect do
          messaging_service.send_efile_submission_successful_submission_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(efile_submission.message_tracker).to include "messages.state_file.successful_submission"
        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, submission: efile_submission, message: message, body_args: body_args)
      end
    end
  end
end