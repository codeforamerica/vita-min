require "rails_helper"

describe BedrockDocScreener do
  describe ".prompt_for" do
    before do
      allow(described_class)
        .to receive(:available_doc_types)
              .and_return([{ key: "w2", label: "W-2" },
                           { key: "1099", label: "1099-MISC" }])
    end

    it "includes the selected document type and available_doc_types" do
      prompt = described_class.prompt_for(document_type: "Employment")

      expect(prompt).to include("Selected document type: Employment")
      expect(prompt).to include('available-doc-types: [{key: "w2", label: "W-2"}, {key: "1099", label: "1099-MISC"}]')
    end
  end

  describe ".construct_bedrock_payload" do
    let(:images) do
      [
        { media_type: "image/png", base64_data: "AAA" },
        { media_type: "image/jpeg", base64_data: "BBB" }
      ]
    end
    let(:user_prompt) { "Check this document please." }

    it "builds the correct payload shape" do
      payload = described_class.construct_bedrock_payload(images: images, user_prompt: user_prompt)

      expect(payload[:anthropic_version]).to eq("bedrock-2023-05-31")
      expect(payload[:max_tokens]).to eq(250)
      expect(payload[:messages].size).to eq(1)

      message = payload[:messages].first
      expect(message[:role]).to eq("user")

      content = message[:content]
      # two images + one text
      expect(content.size).to eq(3)

      image_parts = content.first(2)
      text_part = content.last

      image_parts.each_with_index do |img, idx|
        expect(img[:type]).to eq("image")
        expect(img[:source][:type]).to eq("base64")
        expect(img[:source][:media_type]).to eq(images[idx][:media_type])
        expect(img[:source][:data]).to eq(images[idx][:base64_data])
      end

      expect(text_part[:type]).to eq("text")
      expect(text_part[:text]).to eq(user_prompt)
    end
  end

  describe ".extract_text_from_response" do
    it "concatenates only text-type content and strips whitespace" do
      response = {
        "content" => [
          { "type" => "text", "text" => "First line\n" },
          { "type" => "image", "text" => "ignored" },
          { "type" => "text", "text" => "Second line " }
        ]
      }

      result = described_class.extract_text_from_response(response)

      expect(result).to eq("First line\nSecond line")
    end

    it "returns empty string when no text content" do
      response = { "content" => [{ "type" => "image", "text" => "ignored" }] }

      result = described_class.extract_text_from_response(response)

      expect(result).to eq("")
    end
  end

  describe ".parse_strict_json!" do
    context "when JSON is inside a ```json fenced code block" do
      let(:text) do
        <<~TEXT
          Some preamble
```json
          {
            "matches_doc_type_verdict": "pass",
            "suggested_document_type": "W2",
            "document_quality_issues": [],
            "explanation": "Looks valid",
            "confidence": 0.95
          }
```
        TEXT
      end

      it "extracts and parses the JSON" do
        result = described_class.parse_strict_json!(text)

        expect(result).to eq(
                            "matches_doc_type_verdict" => "pass",
                            "suggested_document_type" => "W2",
                            "document_quality_issues" => [],
                            "explanation" => "Looks valid",
                            "confidence" => 0.95
                          )
      end
    end

    context "when text is just raw JSON" do
      let(:text) do
        <<~JSON
          {
            "matches_doc_type_verdict": "fail",
            "suggested_document_type": null,
            "document_quality_issues": ["unreadable"],
            "explanation": "too blurry",
            "confidence": 0.2
          }
        JSON
      end

      it "parses the JSON directly" do
        result = described_class.parse_strict_json!(text)

        expect(result["matches_doc_type_verdict"]).to eq("fail")
        expect(result["suggested_document_type"]).to be_nil
        expect(result["document_quality_issues"]).to eq(["unreadable"])
      end
    end

    context "when JSON is invalid" do
      it "raises with a helpful error message" do
        text = "not-json-at-all"

        expect { described_class.parse_strict_json!(text) }.to raise_error(RuntimeError, /Bedrock did not return valid JSON/)
      end
    end
  end

  describe ".screen_document!" do
    let(:upload) { instance_double("ActiveStorageUpload") }
    let(:document) { instance_double("Document", upload: upload, document_type: "Employment") }

    let(:raw_model_response_hash) do
      {
        "content" => [
          {
            "type" => "text",
            "text" => <<~JSON_TEXT
```json
              {
                "matches_doc_type_verdict": "pass",
                "suggested_document_type": "Employment",
                "document_quality_issues": [],
                "explanation": "Valid doc",
                "confidence": 0.99
              }
```
            JSON_TEXT
          }
        ]
      }
    end

    let(:fake_body_io) { StringIO.new(raw_model_response_hash.to_json) }
    let(:fake_aws_response) { double("AwsResponse", body: fake_body_io) }

    before do
      allow(upload).to receive(:attached?).and_return(true)
      allow(upload).to receive(:content_type).and_return("image/jpeg")
      allow(upload).to receive(:download).and_return("fake-binary-data")
      allow(described_class).to receive(:invoke_bedrock_model).and_return(fake_aws_response)
    end

    it "raises if the document has no upload" do
      allow(upload).to receive(:attached?).and_return(false)

      expect {
        described_class.screen_document!(document: document)
      }.to raise_error("Document has no upload attached")
    end

    it "raises for unsupported media types" do
      allow(upload).to receive(:content_type).and_return("text/plain")

      expect {
        described_class.screen_document!(document: document)
      }.to raise_error("Unsupported media type: text/plain")
    end

    it "returns parsed result_json and raw_response_json for supported images" do
      result_json, raw_response_json =
        described_class.screen_document!(document: document)

      expect(result_json).to eq(
                               "matches_doc_type_verdict" => "pass",
                               "suggested_document_type" => "Employment",
                               "document_quality_issues" => [],
                               "explanation" => "Valid doc",
                               "confidence" => 0.99
                             )
      expect(raw_response_json).to eq(raw_model_response_hash)

      # sanity check that json is there
      expect(described_class).to have_received(:invoke_bedrock_model) do |arg|
        parsed = JSON.parse(arg)
        expect(parsed["messages"].first["content"].last["text"]).to include("Selected document type: Employment")
      end
    end
  end

  describe ".pdf_to_png_base64" do
    let(:upload) { instance_double("ActiveStorageUpload") }

    before do
      allow(upload).to receive(:download).and_return("%PDF-1.4 ... fake pdf bytes ...") # pretend the "download" returns the PDF bytes
      fake_image = double("MiniMagick::Image")
      fake_pages = [double("page1"), double("page2")] # fake MiniMagick image with two pages
      convert_stub = double("MiniMagick::Tool::Convert").as_null_object
      allow(MiniMagick::Image).to receive(:open).and_return(fake_image)
      allow(fake_image).to receive(:pages).and_return(fake_pages)
      allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(convert_stub)
      allow(File).to receive(:binread).and_return("png-binary-data")
    end

    it "returns an array of png base64 hashes for each page" do
      result = described_class.pdf_to_png_base64(upload)

      expect(result).to all(include(:media_type, :base64_data))
      expect(result.map { |h| h[:media_type] }.uniq).to eq(["image/png"])
      result.each do |h|
        expect(Base64.decode64(h[:base64_data])).to eq("png-binary-data")
      end
    end

    it "raises error when conversion fails" do
      allow(MiniMagick::Image).to receive(:open).and_raise(MiniMagick::Error.new("boom"))

      expect { described_class.pdf_to_png_base64(upload) }.to raise_error(/failed to convert pdf pages to images/)
    end
  end
end