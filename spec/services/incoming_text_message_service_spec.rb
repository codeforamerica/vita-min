require 'rails_helper'

describe IncomingTextMessageService do
  describe ".process" do
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

    let(:current_time) { DateTime.new(2020, 9, 6) }
    before do
      allow(TwilioService).to receive(:valid_request?).and_return true
      allow(DateTime).to receive(:now).and_return current_time
      allow(ClientChannel).to receive(:broadcast_contact_record)
    end

    context "with a matching intake phone number" do
      let(:client) { create :client }
      let!(:intake) { create(:intake, client: client, phone_number: "+15005550006") }

      it "creates a new IncomingTextMessage linked to the client the right data" do
        expect do
          IncomingTextMessageService.process(incoming_message_params)
        end.to change(IncomingTextMessage, :count).by 1

        message = IncomingTextMessage.last
        expect(message.body).to eq "Hello, it me"
        expect(message.from_phone_number).to eq "+15005550006"
        expect(message.received_at).to eq current_time
        expect(message.client).to eq client
      end

      it "broadcasts the message" do
        IncomingTextMessageService.process(incoming_message_params)
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(IncomingTextMessage.last)
      end
    end

    context "without a matching client" do
      it "creates a new incoming text message attached to a new client" do
        expect do
          IncomingTextMessageService.process(incoming_message_params)
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

    context "with three matching client intakes" do
      let!(:client1) { create(:client, intake: (create :intake, phone_number: "+15005550006")) }
      let!(:client2) { create(:client, intake: (create :intake, phone_number: "+15005550006")) }
      let!(:client3) { create(:client, intake: (create :intake, sms_phone_number: "+15005550006")) }
      let!(:client4) { create(:client, intake: (create :intake, sms_phone_number: "+15005550005")) }

      it 'associates the messages with each existing client' do
        expect do
          IncomingTextMessageService.process(incoming_message_params)
        end.to change(IncomingTextMessage.where(client: [client1, client2, client3, client4]), :count).by(3).and change(Client, :count).by(0)
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
        allow_any_instance_of(TwilioService).to receive(:parse_attachments).and_return(parsed_attachments)
      end

      it "creates an incoming text message with the attachments associated" do
        IncomingTextMessageService.process(incoming_message_params)

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