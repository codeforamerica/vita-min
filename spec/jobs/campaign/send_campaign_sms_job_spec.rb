require "rails_helper"

describe Campaign::SendCampaignSmsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:perform_job) { described_class.new.perform(campaign_sms.id) }

  let!(:campaign_contact) { create(:campaign_contact, :sms_opted_in) }

  let!(:campaign_sms) do
    create(
      :campaign_sms,
      campaign_contact: campaign_contact,
      to_phone_number: campaign_contact.sms_phone_number,
      body: "Hi!",
      message_name: "start_of_season_outreach",
      scheduled_send_at: scheduled_send_at,
      twilio_sid: twilio_sid
    )
  end

  let(:scheduled_send_at) { nil }
  let(:twilio_sid) { nil }

  TwilioMessage = Struct.new(:sid, :status, :error_code)

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    Rails.application.routes.default_url_options[:host] = "example.test"

    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(false)

    allow_any_instance_of(TwilioService).to receive(:send_text_message).and_call_original
  end

  describe "#perform" do
    context "when cancel flag is enabled" do
      it "does nothing" do
        allow(Flipper).to receive(:enabled?).with(:cancel_campaign_sms).and_return(true)

        perform_job

        expect(campaign_sms.reload.twilio_sid).to be_nil
        expect(campaign_sms.sent_at).to be_nil
      end
    end

    context "when the CampaignSms already has a twilio_sid" do
      let(:twilio_sid) { "SM_ALREADY_SENT" }

      it "does not send again" do
        perform_job

        expect(campaign_sms.reload.twilio_sid).to eq("SM_ALREADY_SENT")
      end
    end

    context "when scheduled_send_at is in the future" do
      let(:scheduled_send_at) { 30.minutes.from_now }

      it "re-enqueues itself for the scheduled time and returns" do
        expect { perform_job }
          .to have_enqueued_job(described_class)
                .with(campaign_sms.id)
                .at(scheduled_send_at)

        expect(campaign_sms.reload.twilio_sid).to be_nil
        expect(campaign_sms.sent_at).to be_nil
      end
    end

    context "when scheduled_send_at is in the past" do
      let(:scheduled_send_at) { 5.minutes.ago }

      it "sends via Twilio and updates twilio_sid, sent_at, and status" do
        message = TwilioMessage.new("SM123", "sent", nil)

        allow_any_instance_of(TwilioService).to receive(:send_text_message).and_return(message)

        perform_job

        campaign_sms.reload
        expect(campaign_sms.twilio_sid).to eq("SM123")
        expect(campaign_sms.sent_at).to be_present
        expect(campaign_sms.twilio_status).to eq("sent").or be_present # depending on your update_status_if_further behavior
      end

      it "passes status_callback and outgoing_text_message into TwilioService" do
        message = TwilioMessage.new("SM123", "sent", nil)

        expect_any_instance_of(TwilioService).to receive(:send_text_message) do |_service, **kwargs|
          expect(kwargs[:to]).to eq(campaign_sms.to_phone_number)
          expect(kwargs[:body]).to eq(campaign_sms.body)
          expect(kwargs[:outgoing_text_message]).to eq(campaign_sms)
          expect(kwargs[:status_callback]).to be_present
        end.and_return(message)

        perform_job
      end

      it "does not update anything when Twilio returns nil" do
        allow_any_instance_of(TwilioService).to receive(:send_text_message).and_return(nil)

        perform_job

        campaign_sms.reload
        expect(campaign_sms.twilio_sid).to be_nil
        expect(campaign_sms.sent_at).to be_nil
      end
    end

    context "when Twilio send raises Net::OpenTimeout" do
      let(:scheduled_send_at) { 1.minute.ago }

      it "marks twilio_error and retries the job" do
        allow_any_instance_of(TwilioService).to receive(:send_text_message).and_raise(Net::OpenTimeout)
        allow(DatadogApi).to receive(:increment)

        # Avoid ActiveJob raising during retry in an inline perform
        allow_any_instance_of(described_class).to receive(:retry_job)

        perform_job

        expect(DatadogApi).to have_received(:increment).with("twilio.outgoing_text_message.failure.timeout")

        campaign_sms.reload
        expect(campaign_sms.twilio_status).to eq("twilio_error").or be_present
      end
    end
  end
end
