require 'rails_helper'

describe Hub::OutboundCallForm do
  let(:user) { create :admin_user, phone_number: "+18324658840" }
  let(:client) { create :client, intake: (create :intake, phone_number: "+18324651680") }
  context "initialization" do
    context 'with client and user, no custom params' do
      subject { described_class.new(client: client, user: user) }

      it 'sets client_phone_number from client and user_phone_number from user' do
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

  context "dial" do
    subject { described_class.new(client: client, user: user) }
    let(:twilio_double) { double(Twilio::REST::Client) }
    let(:twilio_calls_double) { double }
    let(:twilio_response_double) { double(Twilio::REST::Api::V2010::AccountContext::CallInstance, sid: "123456", status: "initiated") }

    before do
      allow(Twilio::REST::Client).to receive(:new).and_return(twilio_double)
      allow(twilio_double).to receive(:calls).and_return(twilio_calls_double)
      allow(twilio_calls_double).to receive(:create).and_return(twilio_response_double)
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :voice_phone_number).and_return '+14156393361'
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :account_sid).and_return "abc"
      allow(EnvironmentCredentials).to receive(:dig).with(:twilio, :auth_token).and_return "123"
    end

    it "initializes a twilio instance" do
      subject.dial
      expect(Twilio::REST::Client).to have_received(:new).with("abc", "123")
    end

    it "creates a twilio call with appropriate params" do
      subject.dial
      expect(twilio_calls_double).to have_received(:create).with({
                                                                   twiml: subject.twiml,
                                                                   to: user.phone_number,
                                                                   from: '+14156393361'
                                                                 })
    end

    it "returns an OutboundCall object" do
      expect { subject.dial }.to change(OutboundCall, :count).by(1)
      call = OutboundCall.last
      call.twilio_status = twilio_response_double.status
      call.twilio_sid = twilio_response_double.sid
      call.user = user
      call.client = client
      call.to_phone_number = user.phone_number
      call.from_phone_number = client.phone_number
    end
  end

  context "twiml" do
    subject { described_class.new(client: client, user: user)  }

    it "responds with xml" do
      subject.dial
      expect(subject.twiml).to include "<Say>Please wait while we connect your call.</Say>"
      expect(subject.twiml).to include "<Dial>\n<Number statusCallback=\"http://test.host/outbound_calls/#{subject.outbound_call.id}\" statusCallbackEvent=\"answered completed\" statusCallbackMethod=\"POST\">#{subject.outbound_call.to_phone_number}</Number>\n</Dial>"
    end
  end

  context "development environment without ngrok_url set" do
    before do
      allow(Rails).to receive(:env).and_return("development".inquiry)
    end

    subject { described_class.new(client: client, user: user) }

    it "raises an error" do
      expect { subject.dial }.to raise_error Hub::OutboundCallForm::NgrokNeededError
    end
  end
end