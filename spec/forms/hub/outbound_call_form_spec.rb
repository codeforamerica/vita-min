require 'rails_helper'

describe Hub::OutboundCallForm do
  let(:user) { create :admin_user, phone_number: "+18324658840" }
  let(:client) { create :client, intake: (create :intake, phone_number: "+18324651680") }
  context "initialization" do
    context "with client and user, no custom params" do
      subject { described_class.new(client: client, user: user) }

      it "sets client_phone_number from client and user_phone_number from user" do
        expect(subject.user_phone_number).to eq user.phone_number
        expect(subject.client_phone_number).to eq client.phone_number
      end
    end

    context "with custom parameters" do
      subject do
        described_class.new(
            { user_phone_number: user_phone_number, client_phone_number: client_phone_number},
            client: client, user: user)
      end

      let(:user_phone_number) { "+18324657780" }
      let(:client_phone_number) { "+18324650000" }

      it "sets client_phone_number and user_phone_number from params" do
        expect(subject.user_phone_number).to eq user_phone_number
        expect(subject.client_phone_number).to eq client_phone_number
      end
    end
  end

  describe "#dial" do
    subject { described_class.new(client: client, user: user) }
    let(:twilio_double) { double(Twilio::REST::Client) }
    let(:twilio_calls_double) { double }
    let(:twilio_response_double) { double(Twilio::REST::Api::V2010::AccountContext::CallInstance, sid: "123456", status: "initiated", queue_time: "1000") }
    let(:twilio_phone_number) { "+14156393361" }

    before do
      allow(Twilio::REST::Client).to receive(:new).and_return(twilio_double)
      allow(twilio_double).to receive(:calls).and_return(twilio_calls_double)
      allow(twilio_calls_double).to receive(:create).and_return(twilio_response_double)
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :voice_phone_number).and_return twilio_phone_number
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :account_sid).and_return "abc"
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :auth_token).and_return "123"
      allow(DatadogApi).to receive(:increment)
      allow(DatadogApi).to receive(:gauge)
    end

    it "initializes a twilio instance" do
      subject.dial
      expect(Twilio::REST::Client).to have_received(:new).with("abc", "123")
    end

    it "creates a twilio call with appropriate params" do
      subject.dial

      call = OutboundCall.last
      expected_twiml = <<~TWIML
        <?xml version="1.0" encoding="UTF-8"?>
        <Response>
        <Gather action="http://test.host/outbound_calls/connect/#{call.id}" numDigits="1" timeout="15">
        <Say>Press any number to connect your Get Your Refund call.</Say>
        </Gather>
        <Say>We didn't hear from you so we're hanging up!</Say>
        <Hangup/>
        </Response>
      TWIML
      expect(twilio_calls_double).to have_received(:create).with(
        twiml: expected_twiml,
        to: user.phone_number,
        from: twilio_phone_number
      )
    end

    it "returns an OutboundCall object" do
      expect { subject.dial }.to change(OutboundCall, :count).by(1)
      call = OutboundCall.last
      expect(call.twilio_status).to eq twilio_response_double.status
      expect(call.twilio_sid).to eq twilio_response_double.sid
      expect(call.user).to eq user
      expect(call.client).to eq client
      expect(call.to_phone_number).to eq client.phone_number
      expect(call.from_phone_number).to eq user.phone_number
      expect(call.queue_time_ms).to eq twilio_response_double.queue_time.to_i
    end

    it "sends metrics to Datadog" do
      subject.dial

      expect(DatadogApi).to have_received(:increment).with "twilio.outbound_calls.initiated"
      expect(DatadogApi).to have_received(:gauge).with("twilio.outbound_calls.queue_time_ms", twilio_response_double.queue_time.to_i)
    end
  end
end
