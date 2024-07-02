require "rails_helper"

describe StateFile::MessagingService do
  let(:intake) { create :state_file_az_intake, primary_first_name: "Mona", email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, message_tracker: {}, hashed_ssn: "boopbedoop" }
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

    context "email verification" do
      it "does not send message when email is not verified" do
        intake.update(email_address_verified_at: nil)
        expect do
          messaging_service.send_message
        end.not_to change(StateFileNotificationEmail, :count)
      end

      it "does send if matching intake has verified email" do
        intake.update(email_address_verified_at: nil)
        create(:state_file_az_intake, email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, hashed_ssn: intake.hashed_ssn)

        expect do
          messaging_service.send_message
        end.to change(StateFileNotificationEmail, :count).by(1)
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

  context "when message is of finish_return type" do
    let(:message) { StateFile::AutomatedMessage::FinishReturn }
    let!(:messaging_service) { described_class.new(message: message, intake: intake) }

    it "records the messages in the intake message tracker" do
      expect do
        messaging_service.send_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(intake.message_tracker).to include "messages.state_file.finish_return"
    end
  end
end