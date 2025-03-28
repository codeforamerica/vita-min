require 'rails_helper'

RSpec.describe StateFile::SendNotificationTextMessageJob, type: :job do
  describe "#perform" do
    let(:text_message) { create :state_file_notification_text_message }
    let(:twilio_double) { instance_double(TwilioService) }
    let(:fake_twilio_response) { double(sid: "123", status: "sending", error_code: nil) }

    before do
      allow(TwilioService).to receive(:new).and_return(twilio_double)
      allow(twilio_double).to receive(:send_text_message).and_return(fake_twilio_response)
    end

    it "finds the text message record, uses twilio service to send message, updates record" do
      fake_time = DateTime.parse("2025-01-14")
      Timecop.freeze(fake_time) do
        described_class.perform_now(text_message.id)

        expect(TwilioService).to have_received(:new).with(:statefile)
        expect(twilio_double).to have_received(:send_text_message).with(
          to: text_message.to_phone_number,
          body: text_message.body,
          outgoing_text_message: text_message,
        )
        text_message.reload
        expect(text_message.sent_at).to eq fake_time
        expect(text_message.twilio_sid).to eq "123"
        expect(text_message.twilio_status).to eq "sending"
      end
    end

    context "when the message has an error code" do
      let(:fake_twilio_response) { double(sid: "123", status: "sending", error_code: "30007") }

      it "persists the error code" do
        described_class.perform_now(text_message.id)

        text_message.reload
        expect(text_message.error_code).to eq "30007"
      end
    end

    context "when Twilio doesn't return a response in time" do
      let(:fake_twilio_response) { nil }

      it "exits gracefully" do
        expect {
          described_class.perform_now(text_message.id)
        }.not_to raise_error
      end
    end
  end
end
