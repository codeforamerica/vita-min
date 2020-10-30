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

  describe ".valid_request?" do
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

  describe "#parse_attachments" do
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
      let(:service) { TwilioService.new(params) }

      before do
        allow(service).to receive(:fetch_attachment).with(image_url).and_return({
          filename: "a_real_image.jpg",
          body: "image body"
        })
        allow(service).to receive(:fetch_attachment).with(pdf_url).and_return({
          filename: "a_real_document.pdf",
          body: "pdf body"
        })
      end

      it "creates attachment objects from params" do
        result = service.parse_attachments

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
      let(:service) { TwilioService.new(params) }

      it "returns an empty array" do
        expect(service.parse_attachments).to eq []
      end
    end

    context "with invalid attachments" do
      let(:invalid_file_url) { "http://example.com/sadkjkjekjwqr-invalid" }
      let(:params) {
        {
          "NumMedia" => "1",
          "MediaContentType0" => "something/bad",
          "MediaUrl0" => invalid_file_url,
        }
      }
      let(:service) { TwilioService.new(params) }

      before do
        allow(service).to receive(:fetch_attachment).with(invalid_file_url).and_return({
          filename: "a-bad.file",
          body: "some bad content"
        })
      end

      it "returns modified filename, modified content, and text/plain content type" do
        result = service.parse_attachments
        contents = <<~TEXT
          Unusable file with unknown or unsupported file type.
          File name:'a-bad.file'
          File type:'something/bad'
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

  describe "#fetch_attachment" do
    let(:media_url) { "https://example.com/temporary_redirect" }
    let(:params) {
      {
        "NumMedia" => "1",
        "MediaContentType0" => "image/jpeg",
        "MediaUrl0" => media_url,
      }
    }
    let(:service) { TwilioService.new(params) }

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

      expect(service.fetch_attachment(media_url)).to eq result
    end
  end
end
