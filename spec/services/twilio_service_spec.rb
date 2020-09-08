require 'rails_helper'

describe TwilioService do
  let(:request) { double }
  let(:post_data) do
    {
      "ToCountry"=>"US",
      "ToState"=>"OH",
      "SmsMessageSid"=>"SM7067f0beef82c65f976dc2386a7sgd7w",
      "NumMedia"=>"0",
      "ToCity"=>"",
      "FromZip"=>"95050",
      "SmsSid"=>"SM7067f0beef82c65f976dc2386a7sgd7w",
      "FromState"=>"CA",
      "SmsStatus"=>"received",
      "FromCity"=>"LOS GATOS",
      "Body"=>"Hello, it me",
      "FromCountry"=>"US",
      "To"=>"+4158161286",
      "ToZip"=>"",
      "NumSegments"=>"1",
      "MessageSid"=>"SM7067f0beef82c65fb6785v46754v6754",
      "AccountSid"=>"AC70b4e3aa44fe961398q89we7yr98aw7y",
      "From"=>"+15552341122",
      "ApiVersion"=>"2010-04-01"
    }
  end

  before do
    allow(request).to receive(:url).and_return("https://getyourrefund.org/twilio/incoming-message")
    allow(request).to receive(:headers).and_return({"X-Twilio-Signature" => "3n9j719k64iDJt6DfjT6cHWZJHG="})
    allow(request).to receive(:POST).and_return(post_data)
  end

  describe "#valid_request?" do
    let(:request_validator) { instance_double(Twilio::Security::RequestValidator) }
    before do
      allow(Twilio::Security::RequestValidator).to receive(:new).and_return(request_validator)
      allow(request_validator).to receive(:validate).and_return(true)
    end

    it "passes the correct information to the Twilio RequestValidator" do
      result = TwilioService.valid_request?(request)

      expect(result).to eq true
      expect(request_validator).to have_received(:validate).with(
        "https://getyourrefund.org/twilio/incoming-message",
        post_data,
        "3n9j719k64iDJt6DfjT6cHWZJHG="
      )
    end
  end
end
