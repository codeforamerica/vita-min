require "rails_helper"

RSpec.describe Campaign::SendCampaignEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) { described_class.new.perform(email.id) }

  let(:contact) { create(:campaign_contact, email_address: "a@example.com", locale: "es") }
  let(:email) { create(:campaign_email, campaign_contact: contact, mailgun_message_id: nil, scheduled_send_at: nil) }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(false)
  end

  around do |example|
    Timecop.freeze(Time.zone.parse("2026-02-06 10:00:00")) { example.run }
  ensure
    Timecop.return
  end

  describe "#perform" do
    context "when cancel flag is enabled" do
      it "returns" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_emails).and_return(true)

        expect(CampaignEmail).not_to receive(:find)
        perform_job
      end
    end

    context "when the CampaignEmail already has a mailgun_message_id" do
      let(:email) { create(:campaign_email, campaign_contact: contact, mailgun_message_id: "already-sent") }

      it "does nothing" do
        expect(CampaignMailer).not_to receive(:email_message)
        perform_job
      end
    end

    context "when scheduled_send_at is blank (send now)" do
      it "sends via CampaignMailer with locale fallback and updates email fields" do
        response = instance_double(
          "Mail::Message",
          message_id: "<mailgun-id-123>",
          to: ["a@example.com"],
          from: ["noreply@example.com"],
          subject: "Hello!",
          date: Time.current
        )

        mailer_delivery = instance_double("MailerDelivery", deliver_now: response)

        expect(CampaignMailer).to receive(:email_message).with(
          email_address: "a@example.com",
          message_name: email.message_name,
          locale: "es",
          campaign_email_id: email.id
        ).and_return(mailer_delivery)

        expect { perform_job }.to change { email.reload.mailgun_message_id }.from(nil).to("<mailgun-id-123>")

        email.reload
        expect(email.to_email).to eq("a@example.com")
        expect(email.from_email).to eq("noreply@example.com")
        expect(email.subject).to eq("Hello!")
        expect(email.sent_at).to eq(Time.current)
      end

      it "defaults to english" do
        contact.update!(locale: nil)

        response = instance_double(
          "Mail::Message",
          message_id: "<mailgun-id-123>",
          to: ["a@example.com"],
          from: ["noreply@example.com"],
          subject: "Hello!",
          date: Time.current
        )
        mailer_delivery = instance_double("MailerDelivery", deliver_now: response)

        expect(CampaignMailer).to receive(:email_message).with(
          email_address: "a@example.com",
          message_name: email.message_name,
          locale: "en",
          campaign_email_id: email.id
        ).and_return(mailer_delivery)

        perform_job
      end
    end

    context "when in production" do
      it "increments Datadog metric" do
        allow(Rails.env).to receive(:production?).and_return(true)

        response = instance_double(
          "Mail::Message",
          message_id: "<mailgun-id-123>",
          to: ["a@example.com"],
          from: ["noreply@example.com"],
          subject: "Hello!",
          date: Time.current
        )
        mailer_delivery = instance_double("MailerDelivery", deliver_now: response)

        allow(CampaignMailer).to receive(:email_message).and_return(mailer_delivery)

        expect(DatadogApi).to receive(:increment).with("mailgun.campaign_emails.sent")

        perform_job
      end
    end

    context "when a Mailgun communication error occurs" do
      it "marks the email failed with error_code and re-raises" do
        allow(CampaignMailer).to receive(:email_message).and_raise(Mailgun::CommunicationError.new("nope"))

        expect do
          perform_job
        end.to raise_error(Mailgun::CommunicationError)

        email.reload
        expect(email.mailgun_status).to eq("failed")
        expect(email.error_code).to eq("Mailgun::CommunicationError")
      end
    end

    context "when a timeout error occurs" do
      it "marks the email failed with error_code and re-raises" do
        allow(CampaignMailer).to receive(:email_message).and_raise(Net::ReadTimeout)

        expect do
          perform_job
        end.to raise_error(Net::ReadTimeout)

        email.reload
        expect(email.mailgun_status).to eq("failed")
        expect(email.error_code).to eq("Net::ReadTimeout")
      end
    end

    context "when send_at is derived from scheduled_send_at and is in the future" do
      let(:email) { create(:campaign_email, campaign_contact: contact, scheduled_send_at: 10.minutes.from_now) }

      it "does not update mailgun_message_id immediately" do
        expect { perform_job }.not_to change { email.reload.mailgun_message_id }
      end
    end
  end

  describe "#priority" do
    it "is low priority" do
      expect(described_class.new.priority).to eq(100)
    end
  end
end
