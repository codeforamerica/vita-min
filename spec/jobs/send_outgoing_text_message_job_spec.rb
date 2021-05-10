require "rails_helper"

RSpec.describe SendOutgoingTextMessageJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }
    let(:client) { create(:client) }
    let!(:intake) { create :intake, client: client, locale: "es" }
    let(:fake_twilio_message) { double(Twilio::REST::Api::V2010::AccountContext::MessageInstance, sid: "123", status: "sent") }
    let(:outgoing_text_message) { create(:outgoing_text_message, client: client, user: user, to_phone_number: "+15855551212") }
    let(:fake_replacement_parameters_service) { double }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }

    before do
      allow(TwilioService).to receive(:send_text_message).and_return(fake_twilio_message)
      allow(LoginLinkInsertionService).to receive(:insert_links).and_return("body with links")
    end

    it "replaces sensitive parameters, sends the message to Twilio with a callback URL and saves the status" do
      Timecop.freeze(fake_time) { SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id) }
      expect(TwilioService).to have_received(:send_text_message).with(
        to: outgoing_text_message.to_phone_number,
        body: "body with links",
        status_callback: "http://test.host/outgoing_text_messages/#{outgoing_text_message.id}",
      )

      outgoing_text_message.reload
      expect(outgoing_text_message.twilio_sid).to eq "123"
      expect(outgoing_text_message.twilio_status).to eq "sent"
      expect(outgoing_text_message.sent_at).to eq fake_time

      expect(LoginLinkInsertionService).to have_received(:insert_links).with(outgoing_text_message)
    end
  end
end
