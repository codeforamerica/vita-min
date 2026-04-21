require "rails_helper"

RSpec.describe TwilioWebhooksController do
  let(:twilio_service) { instance_double(TwilioService, valid_request?: true) }

  before do
    allow(TwilioService).to receive(:new).and_return(twilio_service)
  end

  describe "#create_incoming_text_message" do
    let(:body) { "Hello, it me" }
    let(:incoming_message_params) do
      {
          "Body" => body,
          "From" => "+15005550006",
          "NumMedia" => "0",
        # NOTE: These keys are not necessary for the controller to do its work. Left
        # in as a comment for documentation purposes
        # "AccountSid" => "AC70b4e3aa44fe961398q89we7yr98aw7y",
        # "ApiVersion" => "2010-04-01"
        # "FromCity" => "LOS GATOS",
        # "FromCountry" => "US",
        # "FromState" => "CA",
        # "FromZip" => "95050",
        # "MessageSid" => "SM7067f0beef82c65fb6785v46754v6754",
        # "NumSegments" => "1",
        # "SmsMessageSid" => "SM7067f0beef82c65f976dc2386a7sgd7w",
        # "SmsSid" => "SM7067f0beef82c65f976dc2386a7sgd7w",
        # "SmsStatus" => "received",
        # "To" => "+14158161286",
        # "ToCity" => "",
        # "ToCountry" => "US",
        # "ToState" => "OH",
        # "ToZip" => "",
      }
    end

    describe "#create_incoming_text_message" do
      context "with an invalid request" do
        before do
          allow(twilio_service).to receive(:valid_request?).and_return false
        end

        it "returns a 403 status code" do
          post :create_incoming_text_message

          expect(response.status).to eq 403
        end
      end

      context "with a valid request" do
        before do
          allow(twilio_service).to receive(:valid_request?).and_return true
          allow(IncomingTextMessageService).to receive(:process)
        end

        it "processes the text in the IncomingTextMessageService" do
          post :create_incoming_text_message, params: incoming_message_params

          expect(IncomingTextMessageService).to have_received(:process).with(hash_including(incoming_message_params))
        end
      end
    end
  end

  describe "#update_outgoing_text_message" do
    let!(:existing_message) { create :outgoing_text_message }

    context "with an invalid request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_outgoing_text_message, params: { id: existing_message.id }

        expect(response.status).to eq 403
      end
    end

    context "with a valid request" do
      let(:params) do
        {
            "SmsSid" => "SM86006fa9b56c465597ce14349as6s7a2",
            "SmsStatus" => "delivered",
            "MessageStatus" => "delivered",
            "To" => "+14083483513",
            "MessageSid" => "SM86006fa9b56c465597ce14987a3f85a2",
            "AccountSid" => "AC70b4e3aa44fe96139823d8f00a46fre7",
            "From" => "+15136133299",
            "ApiVersion" => "2010-04-01",
            "id" => existing_message.id
        }
      end
      before do
        allow(twilio_service).to receive(:valid_request?).and_return true
        allow(DatadogApi).to receive(:increment)
      end

      it "updates the status of the existing message" do
        post :update_outgoing_text_message, params: params

        expect(response).to be_ok
        expect(existing_message.reload.twilio_status).to eq "delivered"
      end

      context "there is an error code" do
        it "updates the error code" do
          post :update_outgoing_text_message, params: params.merge("ErrorCode" => "30007")

          expect(response).to be_ok
          expect(existing_message.reload.error_code).to eq "30007"
        end
      end

      it "signals Datadog" do
        post :update_outgoing_text_message, params: params
        expect(DatadogApi).to have_received(:increment).with "twilio.outgoing_text_messages.updated.status.delivered"
      end
    end
  end

  describe "POST #update_campaign_sms" do
    let(:campaign_sms) { create(:campaign_sms) }

    before do
      allow_any_instance_of(TwilioService).to receive(:valid_request?).and_return(true)
      allow(DatadogApi).to receive(:increment)
    end

    def post_webhook(id: campaign_sms.id, status: "delivered", error_code: nil)
      post :update_campaign_sms, params: { id: id, "MessageStatus" => status, "ErrorCode" => error_code, "MessageSid" => "SM123"}
    end

    context "when the record exists" do
      it "returns 200" do
        post_webhook
        expect(response).to have_http_status(:ok)
      end

      it "updates the status" do
        expect(campaign_sms).to receive(:update_status_if_further).with("delivered", error_code: "")
        allow(CampaignSms).to receive(:find_by).and_return(campaign_sms)
        post_webhook
      end

      it "tracks message status in datadog" do
        expect(DatadogApi).to receive(:increment).with("twilio.campaign_sms.updated", tags: array_including("status:delivered"))
        post_webhook
      end

      context "when there is an error code" do
        it "passes the error code through" do
          expect(campaign_sms).to receive(:update_status_if_further).with("undelivered", error_code: "30008")
          allow(CampaignSms).to receive(:find_by).and_return(campaign_sms)
          post_webhook(status: "undelivered", error_code: "30008")
        end
      end
    end

    context "when the record does not exist" do
      it "returns 200" do
        post_webhook(id: 0)
        expect(response).to have_http_status(:ok)
      end

      it "tracks the missing record" do
        expect(DatadogApi).to receive(:increment).with("twilio.campaign_sms.updated.missing_record")
        post_webhook(id: 0)
      end
    end

    context "when the twilio request is invalid" do
      let(:twilio_service) { instance_double(TwilioService, valid_request?: false) }

      it "returns 403" do
        post_webhook
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#update_status" do
    let!(:existing_message) { create :outgoing_message_status, :sms }

    context "with an invalid request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_status, params: { id: existing_message.id }

        expect(response.status).to eq 403
      end
    end

    context "with a valid request" do
      let(:params) do
        {
          "SmsSid" => "SM86006fa9b56c465597ce14349as6s7a2",
          "SmsStatus" => "delivered",
          "MessageStatus" => "delivered",
          "To" => "+14083483513",
          "MessageSid" => "SM86006fa9b56c465597ce14987a3f85a2",
          "AccountSid" => "AC70b4e3aa44fe96139823d8f00a46fre7",
          "From" => "+15136133299",
          "ApiVersion" => "2010-04-01",
          "id" => existing_message.id
        }
      end

      before do
        allow(twilio_service).to receive(:valid_request?).and_return true
        allow(DatadogApi).to receive(:increment)
      end

      it "updates the status of the existing message" do
        post :update_status, params: params

        expect(response).to be_ok
        expect(existing_message.reload.delivery_status).to eq "delivered"
      end

      context "there is an error code" do
        it "updates the error code" do
          post :update_status, params: params.merge("ErrorCode" => "30007")

          expect(response).to be_ok
          expect(existing_message.reload.error_code).to eq "30007"
        end
      end

      it "signals Datadog" do
        post :update_status, params: params
        expect(DatadogApi).to have_received(:increment).with "twilio.outgoing_messages.updated.status.delivered"
      end
    end
  end

  describe "#update_outbound_call" do
    let!(:outbound_call) { create :outbound_call, twilio_sid: "CA9c1f259a39bcf0e773bbbb2c4c736c9f" }
    let(:params) do
      {   "id" => outbound_call.id,
          "Called" => "+18324658840",
          "ToState" => "TX",
          "CallerCountry" => "US",
          "Direction" => "outbound-api",
          "Timestamp" => "Mon, 21 Dec 2020 15:19:52 +0000",
          "CallbackSource" => "call-progress-events",
          "SipResponseCode" => "200",
          "CallerState" => "CA",
          "ToZip" => "77097",
          "SequenceNumber" => "0",
          "CallSid" => "CA9c1f259a39bcf0e773bbbb2c4c736c9f",
          "To" => "+18324658840",
          "CallerZip" => "94937",
          "ToCountry" => "US",
          "CalledZip" => "77097",
          "ApiVersion" => "2010-04-01",
          "CalledCity" => "HOUSTON",
          "CallStatus" => "completed",
          "Duration" => "1",
          "From" => "+14156393361",
          "CallDuration" => "11",
          "AccountSid" => "ACXXXXXXXXXXXXX",
          "CalledCountry" => "US",
          "CallerCity" => "INVERNESS",
          "ToCity" => "HOUSTON",
          "FromCountry" => "US",
          "Caller" => "+14156393361",
          "FromCity" => "INVERNESS",
          "CalledState" => "TX",
          "FromZip" => "94937",
          "FromState" => "CA"
      }
    end

    context "a signed request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return true
        allow(DatadogApi).to receive(:increment)
        allow(DatadogApi).to receive(:gauge)
      end

      it "finds the corresponding outbound call object and updates the status and call duration" do
        post :update_outbound_call, params: params
        outbound_call.reload
        expect(outbound_call.twilio_status).to eq "completed"
        expect(outbound_call.twilio_call_duration).to eq 11
      end

      it "sends a metric to Datadog" do
        post :update_outbound_call, params: params

        expect(DatadogApi).to have_received(:gauge).with("twilio.outbound_calls.updated.duration", 11)
        expect(DatadogApi).to have_received(:increment).with("twilio.outbound_calls.updated.status.completed")
      end
    end

    context "an unsigned request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_outbound_call, params: params

        expect(response.status).to eq 403
      end
    end
  end

  describe "#outbound_call_connect" do
    let!(:outbound_call) { create :outbound_call, to_phone_number: "+15005551234" }
    let(:params) {{ id: outbound_call.id}}

    context "a signed request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return true
        allow(DatadogApi).to receive(:increment)
      end

      it "responds with xml" do
        post :outbound_call_connect, params: params
        expect(response.media_type).to eq "application/xml"
      end

      it "responds with formatted twiml" do
        post :outbound_call_connect, params: params
        expect(response.body).to include "<Dial>\n<Number statusCallback=\"http://test.host/outbound_calls/#{outbound_call.id}\" statusCallbackEvent=\"answered completed\" statusCallbackMethod=\"POST\">+15005551234</Number>\n</Dial>"
      end

      it "sends an event to Datadog" do
        post :outbound_call_connect, params: params

        expect(DatadogApi).to have_received(:increment).with "twilio.outbound_calls.connected"
      end
    end

    context "an unsigned request" do
      before do
        allow(twilio_service).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_outbound_call, params: params

        expect(response.status).to eq 403
      end
    end
  end
end
