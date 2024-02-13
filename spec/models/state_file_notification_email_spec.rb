# == Schema Information
#
# Table name: state_file_notification_emails
#
#  id             :bigint           not null, primary key
#  body           :string           not null
#  mailgun_status :string           default("sending")
#  sent_at        :datetime
#  subject        :string           not null
#  to             :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  message_id     :string
#
require "rails_helper"

describe StateFileNotificationEmail do
  describe "validations" do
    context "when linked to intake that is unsubscribed" do
      let(:email) { StateFileNotificationEmail.new(to: "test@example.com", body: "hi", subject: "test") }
      let!(:intake) { create :state_file_az_intake, email_address: "test@example.com", unsubscribed_from_email: true }
      before do
        allow(email).to receive(:deliver)
        allow(DatadogApi).to receive(:increment)
      end

      it "is not valid (does not save or deliver)" do
        email.save
        expect(email).not_to be_persisted
        expect(email).not_to have_received(:deliver)
        expect(DatadogApi).to have_received(:increment).with("mailgun.state_file_notification_emails.not_sent_because_unsubscribed")
      end
    end
  end

  describe "after create" do
    let(:email) { StateFileNotificationEmail.new(to: "test@example.com", body: "hi", subject: "test") }
    before do
      allow(email).to receive(:deliver)
    end

    it "calls deliver" do
      email.save!

      expect(email).to have_received(:deliver)
    end
  end
end
