require "rails_helper"

RSpec.describe IncomingTextMessagesController do
  let(:incoming_message_params) do
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

  describe "#create" do
    context "with an invalid request" do
      before do
        allow(TwilioService).to receive(:valid_request?).and_return false
      end

      it "returns a 403 status code" do
        post :create

        expect(response.status).to eq 403
      end
    end

    context "with a valid request" do
      let(:current_time) { DateTime.new(2020, 9, 6) }
      before do
        allow(TwilioService).to receive(:valid_request?).and_return true
        allow(DateTime).to receive(:now).and_return current_time
      end

      context "with a matching client phone number" do
        let!(:existing_client) { create :client, phone_number: "15552341122" }

        it "creates a new IncomingTextMessage linked to the client the right data" do
          expect do
            post :create, params: incoming_message_params
          end.to change(IncomingTextMessage, :count).by 1

          expect(response).to be_ok
          message = IncomingTextMessage.last
          expect(message.body).to eq "Hello, it me"
          expect(message.from_phone_number).to eq "15552341122"
          expect(message.received_at).to eq current_time
          expect(message.client).to eq existing_client
        end
      end

      context "with a matching client sms_phone_number" do
        let!(:existing_client) { create :client, sms_phone_number: "15552341122" }

        it "creates a new IncomingTextMessage linked to the client the right data" do
          expect do
            post :create, params: incoming_message_params
          end.to change(IncomingTextMessage, :count).by 1

          message = IncomingTextMessage.last
          expect(message.client).to eq existing_client
        end
      end

      context "with multiple matching clients" do
        # We have not discussed the best way to handle this scenario
        # This spec is intended to document existing behavior more than
        # prescribe the correct way to handle this.
        let!(:client1) { create :client, sms_phone_number: "15552341122" }
        let!(:client2) { create :client, phone_number: "15552341122" }

        it "creates a new IncomingTextMessage linked to the first client" do
          expect do
            post :create, params: incoming_message_params
          end.to change(IncomingTextMessage, :count).by 1

          message = IncomingTextMessage.last
          expect(message.client).to eq client1
        end
      end

      context "without a matching client" do
        it "creates a new client and creates a new incoming text message linked to that client" do
          expect do
            post :create, params: incoming_message_params
          end.to change(IncomingTextMessage, :count).by(1).and change(Client, :count).by(1)

          message = IncomingTextMessage.last
          expect(message.body).to eq "Hello, it me"
          expect(message.from_phone_number).to eq "15552341122"
          expect(message.received_at).to eq current_time
          client = Client.last
          expect(message.client).to eq client
          expect(client.phone_number).to eq "15552341122"
          expect(client.sms_phone_number).to eq "15552341122"
        end
      end
    end
  end
end
