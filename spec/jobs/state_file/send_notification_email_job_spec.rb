require 'rails_helper'

RSpec.describe StateFile::SendNotificationEmailJob, type: :job do
  describe "#perform" do
    let(:email) { create :state_file_notification_email }
    let(:mailer_double) { double }
    let(:fake_mailer_response) { double(message_id: 32) }

    before do
      allow(StateFile::NotificationMailer).to receive(:user_message).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver_now).and_return(fake_mailer_response)
    end

    it "finds the email record, uses mailer to send message, updates record" do
      fake_time = DateTime.parse("2025-01-14")
      Timecop.freeze(fake_time) do
        described_class.perform_now(email.id)

        expect(StateFile::NotificationMailer).to have_received(:user_message).with(notification_email: email)
        expect(mailer_double).to have_received(:deliver_now)
        email.reload
        expect(email.message_id).to eq "32"
        expect(email.sent_at).to eq fake_time
      end
    end
  end
end
