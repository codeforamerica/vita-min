require "rails_helper"

describe StateFile::MessagingService do
  let(:intake) { create :state_file_az_intake, primary_first_name: "Mona", email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, message_tracker: {} }
  let(:efile_submission) { create :efile_submission, :for_state, data_source: intake }
  let(:message) { StateFile::AutomatedMessage::Welcome }
  let(:body_args) { {intake_id: intake.id} }
  let!(:messaging_service) { described_class.new(message: message, intake: intake, body_args: body_args) }

  context "when has an email_address" do
    it "creates an email and records message in intake message tracker" do
      expect do
        messaging_service.send_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(intake.message_tracker).to include "messages.state_file.welcome"
      expect(efile_submission.message_tracker).to eq({})
    end

    context "intake is unsubscribed from email" do
      it "does not send the email" do
        allow(DatadogApi).to receive(:increment)
        intake.update(unsubscribed_from_email: true)

        expect do
          messaging_service.send_message
        end.not_to change(StateFileNotificationEmail, :count)
        expect(DatadogApi).to have_received(:increment).with("mailgun.state_file_notification_emails.not_sent_because_unsubscribed")
      end
    end
  end

  context "when message is an after_transition_notification" do
    let(:message) { StateFile::AutomatedMessage::Rejected }
    let!(:messaging_service) { described_class.new(message: message, intake: intake, submission: efile_submission, body_args: {return_status_link: "link.com"}) }

    it "records the messages in the efile submission message tracker" do
      expect do
        messaging_service.send_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(efile_submission.message_tracker).to include "messages.state_file.rejected"
      expect(intake.message_tracker).to eq({})
    end
  end
end