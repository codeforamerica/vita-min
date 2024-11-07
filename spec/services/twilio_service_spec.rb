require 'rails_helper'

describe TwilioService do
  before do
    @test_environment_credentials.merge!({
      twilio: {
        gyr: {
          account_sid: 'gyr_account_sid',
          auth_token: 'gyr_token',
          messaging_service_sid: 'gyr_messaging'
        },
        statefile: {
          account_sid: 'fyst_account_sid',
          auth_token: 'fyst_token',
          messaging_service_sid: 'fyst_messaging'
        },
        ctc: {
          account_sid: 'ctc_account_sid',
          auth_token: 'ctc_token',
          messaging_service_sid: 'ctc_messaging'
        }
      }
    })
  end

  describe "multi-tenant support" do
    it "instantiates as a gyr messanger by default" do
      actual = TwilioService.new.messaging_service_sid
      expected = @test_environment_credentials[:twilio][:gyr][:messaging_service_sid]
      expect(actual).to eq expected
    end

    it "can instantiate as a messenger for all the apps the multi-tenant service knows about" do
      MultiTenantService::SERVICE_TYPES.each do |service|
        actual = TwilioService.new(service).messaging_service_sid
        expected = @test_environment_credentials[:twilio][service][:messaging_service_sid]
        expect(actual).to eq expected
      end
    end
  end

  describe ".valid_request?" do
    let(:request) { double }
    let(:post_data) do
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
    let(:request_validator) { instance_double(Twilio::Security::RequestValidator) }
    before do
      allow(request).to receive(:url).and_return("https://getyourrefund.org/twilio/incoming-message")
      allow(request).to receive(:headers).and_return({ "X-Twilio-Signature" => "3n9j719k64iDJt6DfjT6cHWZJHG=" })
      allow(request).to receive(:POST).and_return(post_data)
      allow(Twilio::Security::RequestValidator).to receive(:new).and_return(request_validator)
      allow(request_validator).to receive(:validate).and_return(true)
    end

    it "passes the correct information to the Twilio RequestValidator" do
      twilio_service = TwilioService.new(:gyr)
      result = twilio_service.valid_request?(request)

      expect(result).to eq true
      expect(request_validator).to have_received(:validate).with(
        "https://getyourrefund.org/twilio/incoming-message",
        post_data,
        "3n9j719k64iDJt6DfjT6cHWZJHG="
      )
    end
  end

  describe ".parse_attachments" do
    context "with valid attachments" do
      let(:image_url) { "https://example.com/128eiuwe32" }
      let(:pdf_url) { "https://example.com/ljk12ekewf98" }
      let(:params) {
        {
          "NumMedia" => "2",
          "MediaContentType0" => "image/jpeg",
          "MediaUrl0" => image_url,
          "MediaContentType1" => "application/pdf",
          "MediaUrl1" => pdf_url,
        }
      }

      before do
        @twilio_service = TwilioService.new(:gyr)
        allow(@twilio_service).to receive(:fetch_attachment).with(image_url).and_return({
                                                                                        filename: "a_real_image.jpg",
                                                                                        body: "image body"
                                                                                      })
        allow(@twilio_service).to receive(:fetch_attachment).with(pdf_url).and_return({
                                                                                      filename: "a_real_document.pdf",
                                                                                      body: "pdf body"
                                                                                    })
      end

      it "creates attachment objects from params" do
        result = @twilio_service.parse_attachments(params)

        expected_result = [
          {
            content_type: "image/jpeg",
            filename: "a_real_image.jpg",
            body: "image body"
          },
          {
            content_type: "application/pdf",
            filename: "a_real_document.pdf",
            body: "pdf body"
          }
        ]
        expect(result).to eq expected_result
      end
    end

    context "with no attachments" do
      let(:params) {
        {
          "NumMedia" => "0",
        }
      }

      it "returns an empty array" do
        twilio_service = TwilioService.new(:gyr)
        expect(twilio_service.parse_attachments(params)).to eq []
      end
    end

    context "with invalid attachments" do
      let(:invalid_file_url) { "http://example.com/sadkjkjekjwqr-invalid" }
      let(:params) {
        {
          "NumMedia" => "1",
          "MediaContentType0" => content_type,
          "MediaUrl0" => invalid_file_url,
        }
      }
      before do
        @twilio_service = TwilioService.new(:gyr)
        allow(@twilio_service).to receive(:fetch_attachment).with(invalid_file_url).and_return({
                                                                                               filename: "a-bad.file",
                                                                                               body: file_contents
                                                                                             })
      end

      context "with content type we do not accept" do
        let(:content_type) { "something/bad" }
        let(:file_contents) { "some bad content" }

        it "returns modified filename, modified content, and text/plain content type" do
          result = @twilio_service.parse_attachments(params)
          contents = <<~TEXT
            Unusable file with unknown or unsupported file type.
            File name: a-bad.file
            File type: something/bad
            File size: 16 bytes
          TEXT

          expected_result = [
            {
              content_type: "text/plain;charset=UTF-8",
              filename: "invalid-a-bad.file.txt",
              body: contents
            }
          ]
          expect(result).to eq expected_result
        end
      end

      context "with zero byte file" do
        let(:content_type) { "image/jpeg" }
        let(:file_contents) { "" }

        it "returns modified filename, modified content, and text/plain content type" do
          result = @twilio_service.parse_attachments(params)
          contents = <<~TEXT
            Unusable file with unknown or unsupported file type.
            File name: a-bad.file
            File type: image/jpeg
            File size: 0 bytes
          TEXT

          expected_result = [
            {
              content_type: "text/plain;charset=UTF-8",
              filename: "invalid-a-bad.file.txt",
              body: contents
            }
          ]
          expect(result).to eq expected_result
        end
      end
    end
  end

  describe ".fetch_attachment" do
    let(:media_url) { "https://example.com/temporary_redirect" }
    let(:params) {
      {
        "NumMedia" => "1",
        "MediaContentType0" => "image/jpeg",
        "MediaUrl0" => media_url,
      }
    }
    before do
      moved_permanently = "https://example.com/moved_permanently"
      s3_ok = "https://example.com/s3_ok"
      stub_request(:any, media_url)
        .to_return(status: 307, body: "no body :(", headers: { location: [moved_permanently] })
      stub_request(:any, moved_permanently)
        .to_return(status: 301, body: "still no body :(", headers: { location: [s3_ok] })
      stub_request(:any, s3_ok)
        .to_return(status: 200, body: "~the content~", headers: {
          "content-disposition": ["inline; filename=\"IMG_1410.jpg\""],
        })
    end

    it "returns the filename and body" do
      result = {
        filename: "IMG_1410.jpg",
        body: "~the content~"
      }

      twilio_service = TwilioService.new(:gyr)
      expect(twilio_service.fetch_attachment(media_url)).to eq result
    end
  end

  describe ".client" do
    let(:fake_client) { double }

    before do
      allow(Twilio::REST::Client).to receive(:new).and_return fake_client
    end

    it "uses environment credentials to instantiate a twilio client" do
      result = TwilioService.new(:gyr)
      expect(result).to be_a(TwilioService)
      expect(Twilio::REST::Client).to have_received(:new).with("gyr_account_sid", "gyr_token")
    end
  end

  describe ".send_text_message" do
    let(:fake_client) { double }
    let(:fake_messages_resource) { double }
    let(:fake_message) { double }
    before do
      @twilio_service = TwilioService.new(:statefile)
      allow(@twilio_service).to receive(:client).and_return fake_client
      allow(fake_client).to receive(:messages).and_return fake_messages_resource
      allow(fake_messages_resource).to receive(:create).and_return fake_message
      allow(DatadogApi).to receive(:increment)
    end

    it "sends a text message using the twilio client" do
      result = @twilio_service.send_text_message(
        to: "+15855551212",
        body: "hello there",
        status_callback: "http://example.com"
      )

      expect(result).to eq fake_message
      expect(fake_messages_resource).to have_received(:create).with(
        messaging_service_sid: "fyst_messaging",
        to: "+15855551212",
        body: "hello there",
        status_callback: "http://example.com"
      )
    end

    it "adds an OutgoingMessageStatus status callback if not given" do
      @twilio_service.send_text_message(
        to: "+15855551212",
        body: "hello there"
      )

      expect(fake_messages_resource).to have_received(:create).with(
        messaging_service_sid: "fyst_messaging",
        to: "+15855551212",
        body: "hello there",
      )
    end

    it "sends a metric to Datadog" do
      @twilio_service.send_text_message(
        to: "+15855551212",
        body: "hello there"
      )
      expect(DatadogApi).to have_received(:increment).with "twilio.outgoing_text_messages.sent"
    end

    context "when twilio doesn't want to send a message" do
      let(:outgoing_message_status) { create(:outgoing_message_status, message_type: :sms) }

      before do
        allow(fake_messages_resource).to receive(:create).and_raise(Twilio::REST::RestError.new(400, OpenStruct.new(body: {}, status_code: 21211)))
      end

      it "records twilio_error on the provided record" do
        @twilio_service.send_text_message(
          to: "+15855551212",
          body: "hello there",
          status_callback: "http://example.com",
          outgoing_text_message: outgoing_message_status
        )

        expect(outgoing_message_status.reload.delivery_status).to eq('twilio_error')
      end
    end
  end

  describe ".get_metadata" do
    let(:fake_client) { double }
    let(:fake_metadata) {
      {
        "mobile_network_code" => "800",
        "carrier_name" => "T-Mobile USA, Inc.",
        "error_code" => nil,
        "mobile_country_code" => "310",
        "type" => "mobile"
      }
    }
    before do
      @twilio_service = TwilioService.new(:gyr)
      allow(@twilio_service).to receive(:client).and_return fake_client
      allow(fake_client).to receive_message_chain(:lookups, :v2, :phone_numbers, :fetch, :line_type_intelligence).and_return fake_metadata
    end

    it "sends a text message using the twilio client" do
      result = @twilio_service.get_metadata(phone_number: "+15855551212")

      expect(result).to eq fake_metadata
    end
  end
end
