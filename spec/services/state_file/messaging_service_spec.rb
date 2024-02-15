require "rails_helper"

describe StateFile::MessagingService do
  let(:intake) { create :state_file_az_intake, primary_first_name: "Mona", email_address: "mona@example.com", email_address_verified_at: 1.minute.ago, message_tracker: {} }
  let(:message) { StateFile::AutomatedMessage::Welcome }
  let!(:messaging_service) { described_class.new(message: message, intake: intake) }

  before do
    allow(Flipper).to receive(:enabled?).with(:state_file_notification_emails).and_return(true)
  end

  context "when has an email_address" do
    it "creates an email" do
      expect do
        messaging_service.send_message
      end.to change(StateFileNotificationEmail, :count).by(1)

      expect(intake.message_tracker).to include "messages.state_file.welcome"
    end
  end
end