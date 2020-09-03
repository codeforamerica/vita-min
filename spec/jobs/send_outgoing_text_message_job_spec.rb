require "rails_helper"

RSpec.describe SendOutgoingTextMessageJob, type: :job do
  describe "#perform" do
    let(:user) { create(:user, role: "admin") }
    let(:case_file) { create(:case_file) }
    let(:fake_twilio_client) { double(Twilio::REST::Client) }
    let(:fake_twilio_message) { double(Twilio::REST::Api::V2010::AccountContext::MessageInstance, sid: "123", status: "sent")}
    let(:outgoing_text_message) { create(:outgoing_text_message, case_file: case_file, user: user) }

    before do
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :phone_number).and_return("+15555551212")
      allow(Twilio::REST::Client).to receive(:new).and_return(fake_twilio_client)
    end

    context "in the development environment" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it "send the message to Twilio and saves the status into the model" do
        allow(fake_twilio_client).to receive_message_chain(:messages, :create)
                                       .with(from: "+15555551212", to: case_file.sms_phone_number, body: outgoing_text_message.body)
                                       .and_return(fake_twilio_message)

        SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)

        expect(outgoing_text_message.reload.twilio_sid).to eq "123"
        expect(outgoing_text_message.reload.twilio_status).to eq "sent"
      end
    end

    context "in a non-development environment" do
      before do
        allow(Rails).to receive(:env).and_return("staging".inquiry)
      end

      let(:verifiable_outgoing_text_message_id) do
        ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base).generate(
          outgoing_text_message.id.to_s, purpose: :twilio_text_message_status_callback
        )
      end

      it "send the message to Twilio along with a status callback URL and saves the status into the model" do
        allow(fake_twilio_client).to receive_message_chain(:messages, :create)
          .with(
            from: "+15555551212",
            to: case_file.sms_phone_number,
            body: outgoing_text_message.body,
            status_callback: case_files_text_status_callback_url(
              verifiable_outgoing_text_message_id: verifiable_outgoing_text_message_id
            )
          )
          .and_return(fake_twilio_message)

        SendOutgoingTextMessageJob.perform_now(outgoing_text_message.id)

        expect(outgoing_text_message.reload.twilio_sid).to eq "123"
        expect(outgoing_text_message.reload.twilio_status).to eq "sent"
      end
    end
  end
end
