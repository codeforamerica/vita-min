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
        # allow(SendSurveyNotificationJob).to receive(:perform_later)
      end

=begin
  before do
    allow(SendSignupMessageJob).to receive(:perform_later)
  end

  include_context "rake"
  context "with signup objects that have not been sent the message" do
    it "enqueues a job" do
      ARGV.replace ["signup:send_messages", "ctc_2022_open_message", "1000"]

      task.invoke
      expect(SendSignupMessageJob).to have_received(:perform_later).with("ctc_2022_open_message", 1000)
    end
  end
=end

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

        # send_survey_notification_job = instance_double(SendSurveyNotificationJob)

        expect(SendSurveyNotificationJob).to have_received(:perform_later).with(intake, efile_submission)
        # expect(SendSurveyNotificationJob).to receive(:new).and_return(send_survey_notification_job)
        # expect(send_survey_notification_job).to receive(:set).with(wait_until: 23.hours.from_now)
        # expect(send_survey_notification_job).to receive(:perform_later).with(intake, efile_submission)

        # expect(SendSurveyNotificationJob).to have_received(:set).with(
        #   wait_until: 23.hours.from_now
        # )

        # SendSurveyNotificationJob.set(
        #   wait_until: 23.hours.from_now
        # ).perform_later(@intake, @submission)

        # atm = StateFile::AfterTransitionMessagingService.new(efile_submission)

        # binding.pry

        # expect {
        #   # atm.schedule_survey_notification_job
        #   messaging_service
        # }.to have_enqueued_job(SendSurveyNotificationJob).at(23.hours.from_now).with(intake, efile_submission)

        # expect(SendSurveyNotificationJob).to have_received(:set).with(
        #   intake, efile_submission
        # )


=begin
      SendSurveyNotificationJob.set(
        wait_until: 23.hours.from_now
      ).perform_later(@intake, @submission)
=end
        # expect(SendSurveyNotificationJob).to receive(:set).with(
        #   wait_until: 23.hours.from_now).and_return(SendSurveyNotificationJob
        # )
        # expect(SendSurveyNotificationJob).to receive(:perform_later).with(
        #   intake, efile_submission
        # )
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
        expect(SendSurveyNotificationJob).to have_received(:set).with(intake, efile_submission)


        # expect {
        #   YourClass.new(intake, submission).schedule_survey_notification_job
        # }.to have_enqueued_job(SendSurveyNotificationJob).at(23.hours.from_now).with(intake, submission)
        # expect(SendSurveyNotificationJob).to receive(:set).with(wait_until: 23.hours.from_now).and_return(SendSurveyNotificationJob)
        # expect(SendSurveyNotificationJob).to receive(:perform_later).with(intake: intake, submission: submission)
      end
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

  # describe "#schedule_survey_notification_job" do
  #   let(:message) { StateFile::AutomatedMessage::SurveyNotification }
  #   let(:body_args) { { survey_link: 'https://some_link' } }
  #
  #   it "sends the survey notification" do
  #     expect do
  #       messaging_service.send_efile_submission_rejected_message
  #     end.to change(StateFileNotificationEmail, :count).by(1)
  #
  #     expect(efile_submission.message_tracker).to include "messages.state_file.survey_notification"
  #
  #     expect(StateFile::MessagingService).to have_received(:new).with(
  #       intake: intake,
  #       submission: efile_submission,
  #       message: message,
  #       body_args: body_args
  #     )
  #   end
  # end
end