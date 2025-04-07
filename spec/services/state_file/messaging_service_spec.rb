require "rails_helper"

describe StateFile::MessagingService do
  let(:intake) do
    create(
      :state_file_az_intake,
      primary_first_name: "Mona", phone_number: "+15555555555",
      phone_number_verified_at: 1.minute.ago, email_address: "mona@example.com",
      email_address_verified_at: 1.minute.ago, message_tracker: {}, hashed_ssn: "boopbedoop"
    )
  end

  let(:efile_submission) { create :efile_submission, :for_state, data_source: intake }
  let(:message) { StateFile::AutomatedMessage::Welcome }
  let(:body_args) { { intake_id: intake.id } }
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

      it "should not send a message if email notifications are opted out" do
        intake.update(email_notification_opt_in: "no")

        expect {
          messaging_service.send_message
        }.not_to change(StateFileNotificationEmail, :count)
      end

      it "should send a message if email notifications are opted in" do
        intake.update(email_notification_opt_in: "yes")

        expect {
          messaging_service.send_message
        }.to change(StateFileNotificationEmail, :count).by(1)
      end
    end
  end

  context "when has a phone number" do
    it "should send a message if the number is verified" do
      expect {
        messaging_service.send_message
      }.to change(StateFileNotificationTextMessage, :count).by(1)
    end

    it "should not send a message if the number is unverified" do
      intake.update(phone_number_verified_at: nil)

      expect {
        messaging_service.send_message
      }.to not_change(StateFileNotificationTextMessage, :count)
    end

    it "should not send a message if SMS notifications are opted out" do
      intake.update(sms_notification_opt_in: "no")

      expect {
        messaging_service.send_message
      }.not_to change(StateFileNotificationTextMessage, :count)
    end

    it "should send a message if SMS notifications are opted in" do
      intake.update(sms_notification_opt_in: "yes")

      expect {
        messaging_service.send_message
      }.to change(StateFileNotificationTextMessage, :count).by(1)
    end
  end

  context "when required_verification is false" do
    it "should send email and phone notifications" do
      intake.update(email_address_verified_at: nil)
      intake.update(phone_number_verified_at: nil)
      expect {
        messaging_service.send_message(require_verification: false)
      }.to change(StateFileNotificationEmail, :count).by(1)
      .and change(StateFileNotificationTextMessage, :count).by(1)
    end
  end

  context "when message is an after_transition_notification" do
    let(:message) { StateFile::AutomatedMessage::Rejected }
    let!(:messaging_service) { described_class.new(message: message, intake: intake, submission: efile_submission, body_args: { return_status_link: "link.com" }) }

    it "records the messages in the efile submission message tracker" do
      expect do
        messaging_service.send_message
      end.to change(StateFileNotificationEmail, :count).by(1)
                                                       .and change(StateFileNotificationTextMessage, :count).by(1)

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
                                                       .and change(StateFileNotificationTextMessage, :count).by(1)

      expect(intake.message_tracker).to include "messages.state_file.finish_return"
    end
  end
end
