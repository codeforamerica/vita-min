require "rails_helper"

RSpec.describe SendOutgoingTextMessageJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user, role: "admin") }
    let(:client) { create(:client) }
    let(:fake_twilio_client) { double(Twilio::REST::Client) }
    let(:fake_twilio_messages) { double }
    let(:fake_twilio_message) { double(Twilio::REST::Api::V2010::AccountContext::MessageInstance, sid: "123", status: "sent") }
    let(:outgoing_text_message) { create(:outgoing_text_message, client: client, user: user, to_phone_number: "+15855551212") }

    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :messaging_service_sid).and_return("f@k3s!d")
      allow(Twilio::REST::Client).to receive(:new).and_return(fake_twilio_client)
      allow(fake_twilio_client).to receive(:messages).and_return(fake_twilio_messages)
      allow(fake_twilio_messages).to receive(:create).and_return(fake_twilio_message)
    end

    it "send the message to Twilio along with a status callback URL and saves the status into the model" do
      SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)
      expect(fake_twilio_messages).to have_received(:create).with(
        messaging_service_sid: "f@k3s!d",
        to: outgoing_text_message.to_phone_number,
        body: outgoing_text_message.body,
        status_callback: "http://test.host/outgoing_text_messages/#{outgoing_text_message.id}",
      )

      expect(outgoing_text_message.reload.twilio_sid).to eq "123"
      expect(outgoing_text_message.reload.twilio_status).to eq "sent"
    end
  end
end
