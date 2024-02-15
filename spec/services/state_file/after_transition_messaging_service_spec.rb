require "rails_helper"

describe StateFile::AfterTransitionMessagingService do
  let(:intake) { create :state_file_az_intake, primary_first_name: "Mona", email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, message_tracker: {} }
  let!(:messaging_service) { described_class.new(intake) }
  let(:body_args) { { return_status_link: "http://statefile.test.localhost/en/az/questions/return-status" } }
  let(:message) { StateFile::AutomatedMessage::AcceptedRefund }
  let(:sf_messaging_service) { StateFile::MessagingService.new(intake: intake, message: message, body_args: body_args) }

  before do
    allow(Flipper).to receive(:enabled?).with(:state_file_notification_emails).and_return(true)
    allow(intake).to receive(:calculated_refund_or_owed_amount).and_return(100)
    allow(StateFile::MessagingService).to receive(:new).with(intake: intake, message: message, body_args: body_args).and_return(sf_messaging_service)
  end

  describe "#send_efile_submission_accepted_message" do
    context "when has a refund" do
      it "sends the accepted refund" do
        expect do
          messaging_service.send_efile_submission_accepted_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(intake.message_tracker).to include "messages.state_file.accepted_refund"

        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, message: message, body_args: body_args)
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

      it "sends the accepted owe email" do
        expect do
          messaging_service.send_efile_submission_accepted_message
        end.to change(StateFileNotificationEmail, :count).by(1)

        expect(intake.message_tracker).to include "messages.state_file.accepted_owe"

        expect(StateFile::MessagingService).to have_received(:new).with(intake: intake, message: message, body_args: body_args)
      end
    end
  end
end