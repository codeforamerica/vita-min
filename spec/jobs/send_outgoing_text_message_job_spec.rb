require "rails_helper"

RSpec.describe SendOutgoingTextMessageJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user) }
    let(:client) { create(:client) }
    let!(:intake) { create :intake, client: client, locale: "es" }
    let(:fake_twilio_message) { double(Twilio::REST::Api::V2010::AccountContext::MessageInstance, sid: "123", status: "sent") }
    let(:outgoing_text_message) { create(:outgoing_text_message, client: client, user: user, to_phone_number: "+15855551212") }
    let(:fake_replacement_parameters_service) { double }

    before do
      allow(TwilioService).to receive(:send_text_message).and_return(fake_twilio_message)
      allow(ReplacementParametersService).to receive(:new).and_return(fake_replacement_parameters_service)
      allow(fake_replacement_parameters_service).to receive(:process_sensitive_data).and_return("sensitive body")
    end

    it "replaces sensitive parameters, sends the message to Twilio with a callback URL and saves the status" do
      SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)
      expect(TwilioService).to have_received(:send_text_message).with(
        to: outgoing_text_message.to_phone_number,
        body: "sensitive body",
        status_callback: "http://test.host/outgoing_text_messages/#{outgoing_text_message.id}",
      )

      expect(outgoing_text_message.reload.twilio_sid).to eq "123"
      expect(outgoing_text_message.reload.twilio_status).to eq "sent"

      expect(ReplacementParametersService).to have_received(:new).with(
        body: outgoing_text_message.body,
        client: client,
        locale: intake.locale
      )
      expect(fake_replacement_parameters_service).to have_received(:process_sensitive_data)
    end
  end
end
