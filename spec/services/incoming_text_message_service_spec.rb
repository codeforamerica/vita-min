require 'rails_helper'

describe IncomingTextMessageService, requires_default_vita_partners: true, active_job: true do
  describe ".process" do
    let(:twilio_service) { instance_double TwilioService }
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
      allow(TwilioService).to receive(:new).and_return twilio_service
      allow(twilio_service).to receive(:valid_request?).and_return true
      allow(twilio_service).to receive(:parse_attachments).and_return([])
      allow(DateTime).to receive(:now).and_return current_time
      allow(ClientChannel).to receive(:broadcast_contact_record)
      allow(DatadogApi).to receive(:increment)
      allow(IntercomService).to receive(:create_message)
      allow(IntercomService).to receive(:inform_client_of_handoff)
      allow(TransitionNotFilingService).to receive(:run)
    end

    context "with a matching intake phone number" do
      let!(:client) { create :client, intake: intake, tax_returns: tax_returns }
      let(:tax_returns) { [(build :gyr_tax_return, :prep_preparing)] }
      let(:intake) { build(:intake, phone_number: "+15005550006") }

      it "creates a new IncomingTextMessage linked to the client with the right data" do
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

      it "sends a metric to Datadog" do
        IncomingTextMessageService.process(incoming_message_params)

        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.received")
        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.client_found")
      end

      context "has all tax return status in file_accepted, file_mailed or file_not_filing" do
        let!(:tax_returns) { [(build :gyr_tax_return, :file_not_filing), (build :tax_return, :file_accepted, year: 2019)] }

        before do
          AdminToggle.create(name: AdminToggle::FORWARD_MESSAGES_TO_INTERCOM, value: true, user: create(:admin_user))
        end

        it "creates an intercom message for client" do
          IncomingTextMessageService.process(incoming_message_params)

          expect(IntercomService).to have_received(:create_message).with(body: IncomingTextMessage.last.body, client: client, has_documents: false, email_address: nil, phone_number: client.intake.phone_number)
          expect(IntercomService).to have_received(:inform_client_of_handoff).with(client: client, send_sms: true, send_email: false)
        end
      end

      context "doesn't have tax return status in file_accepted, file_mailed or file_not_filing" do
        it "doesn't creates an intercom message for client" do
          IncomingTextMessageService.process(incoming_message_params)

          expect(IntercomService).not_to have_received(:inform_client_of_handoff)
          expect(IntercomService).not_to have_received(:create_message)
        end
      end
    end

    context "with a matching intake phone number that has not yet consented to service" do
      let!(:non_consenting_client) { create(:client, consented_to_service_at: nil, intake: (build :intake, phone_number: "+15005550006")) }

      it "sends a response not monitored message" do
        IncomingTextMessageService.process(incoming_message_params)
        expect(SendOutgoingTextMessageWithoutClientJob).to have_been_enqueued
      end
    end

    context "without a matching client from the current years intake" do
      it "sends a response not monitored message" do
        IncomingTextMessageService.process(incoming_message_params)
        expect(SendOutgoingTextMessageWithoutClientJob).to have_been_enqueued
      end

      it "sends a metric to Datadog" do
        IncomingTextMessageService.process(incoming_message_params)

        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.received")
        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.client_not_found")
        expect(DatadogApi).to have_received(:increment).with("twilio.outgoing_text_messages.sent_replies_not_monitored")
      end
    end

    context "with three matching client intakes" do
      let!(:client1) { create(:client, intake: (build :intake, phone_number: "+15005550006")) }
      let!(:client2) { create(:client, intake: (build :intake, phone_number: "+15005550006")) }
      let!(:client3) { create(:client, intake: (build :intake, sms_phone_number: "+15005550006")) }
      let!(:client4) { create(:client, intake: (build :intake, sms_phone_number: "+15005550005")) }

      it "associates the messages with each existing client" do
        expect do
          IncomingTextMessageService.process(incoming_message_params)
        end.to change(IncomingTextMessage.where(client: [client1, client2, client3, client4]), :count).by(3).and change(Client, :count).by(0)
      end

      it "calls the TransitionNotFilingService status service for each client" do
        IncomingTextMessageService.process(incoming_message_params)
        expect(TransitionNotFilingService).to have_received(:run).exactly(3).times
      end

      it "sends a metric to Datadog" do
        IncomingTextMessageService.process(incoming_message_params)

        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.received")
        expect(DatadogApi).to have_received(:increment).with("twilio.incoming_text_messages.client_found_multiple")
      end
    end

    context "with an attachment" do
      let!(:client) { create :client, intake: intake }
      let(:intake) { build :intake, sms_phone_number: "+15005550006" }
      let(:body) { "" }
      let(:parsed_attachments) do
        [{content_type: "image/jpeg", filename: "some-type-of-image.jpg", body: "image file contents" }]
      end

      before do
        allow(ClientChannel).to receive(:broadcast_contact_record)
        allow(twilio_service).to receive(:parse_attachments).and_return(parsed_attachments)
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
