require 'rails_helper'

RSpec.describe StateFile::SendRejectResolutionReminderNotificationJob, type: :job do
  describe "#perform" do
    let(:intake) {
      create :state_file_az_intake,
             efile_submissions: efile_subimissions,
             primary_first_name: "Mona",
             email_address: "monalisa@example.com",
             email_address_verified_at: 1.minute.ago,
             message_tracker: {}
    }
    let(:efile_subimissions) { [create(:efile_submission, :notified_of_rejection)] }
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

    context "with an intake that has been sent a notified-of-rejection message, does not have an accepted return and is not currently in an in-progress state" do
      it "sends the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(1)

        expect(intake.reload.message_tracker).to include("messages.state_file.reject_resolution_reminder")

        expect(StateFile::MessagingService).to have_received(:new).with(
          intake: intake,
          message: message,
          body_args: body_args)
      end
    end

    context "with an intake that has not been sent the notified-of-rejection message" do
      let(:efile_subimissions) { [create(:efile_submission, :rejected)] }

      it "does not send the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(0)

        expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
      end
    end

    context "with an intake that has an accepted return" do
      let(:efile_subimissions) { [create(:efile_submission, :notified_of_rejection), create(:efile_submission, :accepted)] }

      it "does not send the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(0)

        expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
      end
    end

    context "currently in transmitted state" do
      let(:efile_subimissions) { [create(:efile_submission, :notified_of_rejection), create(:efile_submission, :transmitted)] }

      it "does not send the message" do
        expect {
          described_class.perform_now(intake)
        }.to change(StateFileNotificationEmail, :count).by(0)

        expect(intake.reload.message_tracker).not_to include("messages.state_file.reject_resolution_reminder")
      end
    end
  end
end
