require "rails_helper"

RSpec.describe TwilioWebhooksController do
  describe "#create_incoming_text_message" do
    let(:body) { "Hello, it me" }
    let(:incoming_message_params) do
      {
          "ToCountry" => "US",
          "ToState" => "OH",
          "SmsMessageSid" => "SM7067f0beef82c65f976dc2386a7sgd7w",
          "NumMedia" => "0",
          "ToCity" => "",
          "FromZip" => "95050",
          "SmsSid" => "SM7067f0beef82c65f976dc2386a7sgd7w",
          "FromState" => "CA",
          "SmsStatus" => "received",
          "FromCity" => "LOS GATOS",
          "Body" => body,
          "FromCountry" => "US",
          "To" => "+14158161286",
          "ToZip" => "",
          "NumSegments" => "1",
          "MessageSid" => "SM7067f0beef82c65fb6785v46754v6754",
          "AccountSid" => "AC70b4e3aa44fe961398q89we7yr98aw7y",
          "From" => "+15005550006",
          "ApiVersion" => "2010-04-01"
      }
    end

    describe "#create" do
      context "with an invalid request" do
        before do
          allow(TwilioService).to receive(:valid_request?).and_return false
        end

        it "returns a 403 status code" do
          post :create_incoming_text_message

          expect(response.status).to eq 403
        end
      end

      context "with a valid request" do
        let(:current_time) { DateTime.new(2020, 9, 6) }
        before do
          allow(TwilioService).to receive(:valid_request?).and_return true
          allow(DateTime).to receive(:now).and_return current_time
        end

        context "with a matching intake phone number" do
          let(:client) { create :client }
          let!(:intake) { create(:intake, client: client, phone_number: "+15005550006") }

          it "creates a new IncomingTextMessage linked to the client the right data" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by 1

            expect(response).to be_ok
            message = IncomingTextMessage.last
            expect(message.body).to eq "Hello, it me"
            expect(message.from_phone_number).to eq "+15005550006"
            expect(message.received_at).to eq current_time
            expect(message.client).to eq client
          end
        end

        context "with a matching client sms_phone_number" do
          before do
            allow(ClientChannel).to receive(:broadcast_contact_record)
          end
          let(:intake) { create(:intake, sms_phone_number: "+15005550006")}
          let!(:client) { create :client, intake: intake }

          it "creates a new IncomingTextMessage linked to the client the right data" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by 1

            message = IncomingTextMessage.last
            expect(message.client).to eq client
          end

          it "sends a real-time update to anyone on this client's page" do
            post :create_incoming_text_message, params: incoming_message_params
            expect(ClientChannel).to have_received(:broadcast_contact_record).with(IncomingTextMessage.last)
          end
        end

        context "with multiple matching clients" do
          # We have not discussed the best way to handle this scenario
          # This spec is intended to document existing behavior more than
          # prescribe the correct way to handle this.
          let(:intake1) { create :intake, phone_number: "+15005550006" }
          let(:intake2) { create :intake, sms_phone_number: "+15005550006" }
          let!(:client1) { create :client, intake: intake1 }
          let!(:client2) { create :client, intake: intake2 }

          it "creates a new IncomingTextMessage linked to the first client" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by 1

            message = IncomingTextMessage.last
            expect(message.client).to eq client1
          end
        end

        context "without a matching client" do
          it "creates a new incoming text message attached to a new client" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by(1).and change(Client, :count).by(1)

            message = IncomingTextMessage.last
            expect(message.body).to eq "Hello, it me"
            expect(message.from_phone_number).to eq "+15005550006"
            expect(message.received_at).to eq current_time
            client = Client.last
            expect(message.client).to eq client
            expect(client.intake.phone_number).to eq "+15005550006"
            expect(client.intake.sms_phone_number).to eq "+15005550006"
            expect(client.intake.sms_notification_opt_in).to eq("yes")
            expect(client.vita_partner).to eq VitaPartner.client_support_org
          end
        end

        context "with an attachment" do
          let!(:client) { create :client }
          let!(:intake) { create :intake, client: client, sms_phone_number: "+15005550006" }
          let(:body) { "" }
          let(:parsed_attachments) do
            [{content_type: "image/jpeg", filename: "some-type-of-image.jpg", body: "image file contents"}]
          end

          before do
            allow(ClientChannel).to receive(:broadcast_contact_record)
            #TODO: use fake instead
            allow_any_instance_of(TwilioService).to receive(:parse_attachments).and_return(parsed_attachments)
          end

          it "creates a new IncomingTextMessage linked to the client the right data" do
            post :create_incoming_text_message, params: incoming_message_params

            documents = client.documents

            expect(documents.count).to eq(1)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::TextMessageAttachment.key])
            expect(documents.first.contact_record).to eq IncomingTextMessage.last
            expect(documents.first.upload.blob.download).to eq("image file contents")
            expect(documents.first.upload.blob.content_type).to eq("image/jpeg")
          end
        end
      end
    end
  end

  describe "#update_outgoing_text_message" do
    let!(:existing_message) { create :outgoing_text_message }

    context "with an invalid request" do
      before do
        allow(TwilioService).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_outgoing_text_message, params: {id: existing_message.id}

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
        allow(TwilioService).to receive(:valid_request?).and_return true
      end

      it "updates the status of the existing message" do
        post :update_outgoing_text_message, params: params

        expect(response).to be_ok
        expect(existing_message.reload.twilio_status).to eq "delivered"
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
        allow(TwilioService).to receive(:valid_request?).and_return true
      end

      it "finds the corresponding outbound call object and updates the status and call duration" do
        post :update_outbound_call, params: params
        outbound_call.reload
        expect(outbound_call.twilio_status).to eq "completed"
        expect(outbound_call.twilio_call_duration).to eq 11
      end
    end

    context "an unsigned request" do
      before do
        allow(TwilioService).to receive(:valid_request?).and_return false
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
        allow(TwilioService).to receive(:valid_request?).and_return true
      end

      it "responds with xml" do
        post :outbound_call_connect, params: params
        expect(response.media_type).to eq "application/xml"
      end

      it "responds with formatted twiml" do
        post :outbound_call_connect, params: params
        expect(response.body).to include "<Dial>\n<Number statusCallback=\"http://test.host/outbound_calls/#{outbound_call.id}\" statusCallbackEvent=\"answered completed\" statusCallbackMethod=\"POST\">+15005551234</Number>\n</Dial>"
      end
    end

    context "an unsigned request" do
      before do
        allow(TwilioService).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :update_outbound_call, params: params

        expect(response.status).to eq 403
      end
    end
  end
end
