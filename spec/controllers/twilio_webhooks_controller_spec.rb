require "rails_helper"

RSpec.describe TwilioWebhooksController do
  describe "#create_incoming_text_message" do
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
          "Body" => "Hello, it me",
          "FromCountry" => "US",
          "To" => "+4158161286",
          "ToZip" => "",
          "NumSegments" => "1",
          "MessageSid" => "SM7067f0beef82c65fb6785v46754v6754",
          "AccountSid" => "AC70b4e3aa44fe961398q89we7yr98aw7y",
          "From" => "+15552341122",
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
          let!(:intake) { create(:intake, client: client, phone_number: "15552341122") }

          it "creates a new IncomingTextMessage linked to the client the right data" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by 1

            expect(response).to be_ok
            message = IncomingTextMessage.last
            expect(message.body).to eq "Hello, it me"
            expect(message.from_phone_number).to eq "15552341122"
            expect(message.received_at).to eq current_time
            expect(message.client).to eq client
          end
        end

        context "with a matching client sms_phone_number" do
          before do
            allow(ClientChannel).to receive(:broadcast_contact_record)
          end
          let(:intake) { create(:intake, sms_phone_number: "15552341122")}
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
          let(:intake1) { create :intake, phone_number: "15552341122" }
          let(:intake2) { create :intake, sms_phone_number: "15552341122" }
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
          it "creates a new client and creates a new incoming text message linked to that client" do
            expect do
              post :create_incoming_text_message, params: incoming_message_params
            end.to change(IncomingTextMessage, :count).by(1).and change(Client, :count).by(1)

            message = IncomingTextMessage.last
            expect(message.body).to eq "Hello, it me"
            expect(message.from_phone_number).to eq "15552341122"
            expect(message.received_at).to eq current_time
            client = Client.last
            expect(message.client).to eq client
            expect(client.intake.phone_number).to eq "15552341122"
            expect(client.intake.sms_phone_number).to eq "15552341122"
          end
        end

        context "with an attachment" do
          let!(:client) { create :client }
          let!(:intake) { create :intake, client: client, sms_phone_number: "15552341122" }
          let(:media_url) { "https://example.com/temporary_redirect" }
          let(:params_with_attachment) do
            incoming_message_params.update({
               "MediaContentType0" => "image/jpeg",
               "MediaUrl0" => media_url,
               "NumMedia" => "1",
             })
          end

          before do
            moved_permanently = "https://example.com/moved_permanently"
            s3_ok = "https://example.com/s3_ok"
            stub_request(:any, media_url)
              .to_return(status: 307, body: "no body :(", headers: { location: [moved_permanently] })
            stub_request(:any, moved_permanently)
              .to_return(status: 301, body: "still no body :(", headers: { location: [s3_ok] })
            stub_request(:any, s3_ok)
              .to_return(status: 200, body: "real body!!", headers: {
                "content-disposition": ["inline; filename=\"IMG_1410.jpg\""],
              })

            allow(ClientChannel).to receive(:broadcast_contact_record)
          end

          it "creates a new IncomingTextMessage linked to the client the right data" do
            post :create_incoming_text_message, params: params_with_attachment

            documents = client.documents

            expect(documents.count).to eq(1)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::TextMessageAttachment.key])
            expect(documents.first.contact_record).to eq IncomingTextMessage.last
            expect(documents.first.upload.blob.download).to eq("real body!!")
            expect(documents.first.upload.blob.content_type).to eq("image/jpeg")
          end
        end

        context "with attachments with bad or blank file types" do
          let!(:client) { create :client }
          let!(:intake) { create :intake, client: client, sms_phone_number: "15552341122" }
          let(:params_with_attachment) do
            incoming_message_params.update({
               "MediaContentType0" => "application/x-ms-dos-executable",
               "MediaContentType1" => "",
               "MediaUrl0" => "https://example.com/0",
               "MediaUrl1" => "https://example.com/1",
               "NumMedia" => "2",
             })
          end

          before do
            (0..1).each do |path|
              moved_permanently = "https://example.com/moved_permanently-#{path}"
              s3_ok = "https://example.com/s3_ok-#{path}"
              stub_request(:any, "https://example.com/#{path}")
                .to_return(status: 307, body: "no body :(", headers: { location: [moved_permanently] })
              stub_request(:any, moved_permanently)
                .to_return(status: 301, body: "still no body :(", headers: { location: [s3_ok] })
              stub_request(:any, s3_ok)
                .to_return(status: 200, body: "real body!!", headers: {
                  "content-disposition": ["inline; filename=\"bad_file\""],
                })
            end

            allow(ClientChannel).to receive(:broadcast_contact_record)
          end

          it "creates a new IncomingTextMessage linked to the client the right data" do
            post :create_incoming_text_message, params: params_with_attachment

            documents = client.documents

            expect(documents.count).to eq(2)
            expect(documents.all.pluck(:document_type).uniq).to eq([DocumentTypes::TextMessageAttachment.key])

            executable_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name:'bad_file'
              File type:'application/x-ms-dos-executable'
            TEXT
            expect(documents.first.upload.blob.download).to eq(executable_message)
            expect(documents.first.upload.blob.content_type).to eq("text/plain;charset=UTF-8")
            expect(documents.first.upload.blob.filename.to_s).to end_with(".txt")

            unknown_file_type_message = <<~TEXT
              Unusable file with unknown or unsupported file type.
              File name:'bad_file'
              File type:''
            TEXT
            expect(documents.second.upload.blob.download).to eq(unknown_file_type_message)
            expect(documents.second.upload.blob.content_type).to eq("text/plain;charset=UTF-8")
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
end
