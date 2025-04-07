require 'rails_helper'

RSpec.describe StateFile::SendRejectResolutionReminderNotificationJob, type: :job do
  describe "#perform" do
    let(:intake) {
      create :state_file_az_intake,
             efile_submissions: efile_submissions,
             primary_first_name: "Mona",
             email_address: "monalisa@example.com",
             email_address_verified_at: 1.minute.ago,
             message_tracker: {}
    }
    let(:current_state) { :notified_of_rejection }
    let(:efile_submissions) { [create(:efile_submission, current_state)] }
    let(:message) { StateFile::AutomatedMessage::RejectResolutionReminder }
    let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/questions/return-status" } }
    let(:sf_messaging_service) {
      StateFile::MessagingService.new(
      intake: intake,
      message: message,
      body_args: body_args)
    }

    before do
      allow(StateFile::MessagingService).to receive(:new).with(intake: intake, message: message, body_args: body_args).and_return(sf_messaging_service)
    end

    context "with an intake that has been sent a notified-of-rejection message, does not have an accepted return" do
      context "is currently in waiting state" do
        let(:current_state) { :waiting }
        before do
          efile_submissions.first.efile_submission_transitions.first.update(sort_key: 1)
          create(:efile_submission_transition, :notified_of_rejection, efile_submission: efile_submissions.first, most_recent: false, sort_key: 0)
        end

        it "sends the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args)

          # can re-send if message was sent before (send 13th & 23rd in 2025)
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args).exactly(2).times
        end
      end

      context "is currently in notified_of_rejection state" do
        let(:current_state) { :notified_of_rejection }

        it "sends the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args)

          # can re-send if message was sent before (send 13th & 23rd in 2025)
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(1)

          expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

          expect(StateFile::MessagingService).to have_received(:new).with(
            intake: intake,
            message: message,
            body_args: body_args).exactly(2).times
        end
      end
    end

    context "with an intake that has an accepted return" do
      let(:efile_submissions) { [create(:efile_submission, :notified_of_rejection), create(:efile_submission, :accepted)] }

      it "does not send the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(0)

        expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
      end
    end

    [:preparing, :bundling, :queued, :transmitted, :ready_for_ack, :failed, :accepted, :rejected, :investigating, :fraud_hold, :resubmitted, :cancelled].each do |state|
      context "currently in #{state} state which is not notified_of_rejection or waiting, even though it has notified_of_rejection in the past" do
        let(:current_state) { state }

        before do
          efile_submissions.first.efile_submission_transitions.first.update(sort_key: 1)
          create(:efile_submission_transition, :notified_of_rejection, efile_submission: efile_submissions.first, most_recent: false, sort_key: 0)
        end

        it "does not send the message" do
          expect {
            described_class.perform_now(intake)
          }.to change(StateFileNotificationEmail, :count).by(0)

          expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
        end
      end
    end
  end
end
