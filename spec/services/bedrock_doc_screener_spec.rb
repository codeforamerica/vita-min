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
      expect(payload[:max_tokens]).to eq(BedrockDocScreener::MAX_TOKENS)
      expect(payload[:messages].size).to eq(2)

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

    it "prefills the assistant turn with an opening brace" do
      payload = described_class.construct_bedrock_payload(images: images, user_prompt: user_prompt)

      expect(payload[:messages].last).to eq(role: "assistant", content: "{")
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

    context "when the JSON is followed by a note" do
      let(:text) do
        <<~TEXT
          {
            "matches_doc_type_verdict": "pass",
            "suggested_document_type": "W2",
            "document_quality_issues": ["N/A"],
            "explanation": "Looks valid",
            "confidence": 0.95
          }

          Note: the {employer} section is partially cropped but still legible.
        TEXT
      end

      it "parses the JSON object and ignores the note" do
        result = described_class.parse_strict_json!(text)

        expect(result["matches_doc_type_verdict"]).to eq("pass")
        expect(result["confidence"]).to eq(0.95)
      end
    end

    context "when JSON is invalid" do
      it "raises with a helpful error message" do
        text = "not-json-at-all"

        expect { described_class.parse_strict_json!(text) }.to raise_error(BedrockDocScreener::InvalidResponseError, /Bedrock did not return valid JSON/)
      end
    end

    context "when the JSON has a trailing comma" do
      it "raises InvalidResponseError" do
        text = '{"matches_doc_type_verdict": "pass", "confidence": 0.95,}'

        expect { described_class.parse_strict_json!(text) }.to raise_error(BedrockDocScreener::InvalidResponseError)
      end
    end
  end

  describe ".screen_document!" do
    let(:upload) { instance_double("ActiveStorageUpload") }
    let(:document) { instance_double("Document", upload: upload, document_type: "Employment") }

    let(:stop_reason) { "end_turn" }
    # the model continues from the "{" prefill, so the response has no opening brace
    let(:generated_text) do
      <<~JSON_TEXT
          "matches_doc_type_verdict": "pass",
          "suggested_document_type": "Employment",
          "document_quality_issues": [],
          "explanation": "Valid doc",
          "confidence": 0.99
        }
      JSON_TEXT
    end
    let(:raw_model_response_hash) do
      {
        "content" => [{ "type" => "text", "text" => generated_text }],
        "stop_reason" => stop_reason
      }
    end

    let(:fake_body_io) { StringIO.new(raw_model_response_hash.to_json) }
    let(:fake_aws_response) { double("AwsResponse", body: fake_body_io) }

    before do
      allow(upload).to receive(:attached?).and_return(true)
      allow(upload).to receive(:content_type).and_return("image/jpeg")
      allow(upload).to receive(:download).and_return(File.binread(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")))
      allow(described_class).to receive(:invoke_bedrock_model).and_return(fake_aws_response)
    end

    it "raises if the document has no upload" do
      allow(upload).to receive(:attached?).and_return(false)

      expect {
        described_class.screen_document!(document: document)
      }.to raise_error("Document has no upload attached")
    end

    it "raises for unsupported media types" do
      allow(upload).to receive(:content_type).and_return("text/html")

      expect {
        described_class.screen_document!(document: document)
      }.to raise_error(BedrockDocScreener::UnsupportedMediaTypeError, "Unsupported media type: text/html")
    end

    it "sends the media type detected from the bytes, not the stored content type" do
      allow(upload).to receive(:content_type).and_return("image/jpeg")
      allow(upload).to receive(:download).and_return(File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")))

      described_class.screen_document!(document: document)

      expect(described_class).to have_received(:invoke_bedrock_model) do |arg|
        parsed = JSON.parse(arg)
        expect(parsed["messages"].first["content"].first["source"]["media_type"]).to eq("image/png")
      end
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
        expect(parsed["messages"].last).to eq("role" => "assistant", "content" => "{")
      end
    end

    context "when the response was cut off at max_tokens" do
      let(:stop_reason) { "max_tokens" }
      let(:generated_text) { '"matches_doc_type_verdict": "pass", "explanation": "The document' }

      it "raises InvalidResponseError carrying the raw response" do
        expect {
          described_class.screen_document!(document: document)
        }.to raise_error(BedrockDocScreener::InvalidResponseError, /cut off/) { |e|
          expect(e.raw_response_json).to eq(raw_model_response_hash)
        }
      end
    end

    context "when the response is not valid JSON" do
      let(:generated_text) { '"matches_doc_type_verdict": "pass", "confidence": 0.95,}' }

      it "raises InvalidResponseError carrying the raw response" do
        expect {
          described_class.screen_document!(document: document)
        }.to raise_error(BedrockDocScreener::InvalidResponseError, /did not return valid JSON/) { |e|
          expect(e.raw_response_json).to eq(raw_model_response_hash)
        }
      end
    end
  end

  describe ".pdf_to_png_base64" do
    let(:upload) { instance_double("ActiveStorageUpload") }
    let!(:png_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }

    before do
      allow(upload).to receive(:download).and_return("%PDF-1.4 ... fake pdf bytes ...") # pretend the "download" returns the PDF bytes
      allow(Dir).to receive(:mktmpdir).and_yield("/tmp/fake_dir")
      allow(described_class).to receive(:system).and_return(true)
      allow(Dir).to receive(:glob).and_return(%w[/tmp/fake_dir/page-1.png /tmp/fake_dir/page-2.png])
      allow(File).to receive(:binread).and_return(png_data)
    end

    it "returns an array of png base64 hashes for each page" do
      result = described_class.pdf_to_png_base64(upload)

      expect(result).to all(include(:media_type, :base64_data))
      expect(result.map { |h| h[:media_type] }.uniq).to eq(["image/png"])
      result.each do |h|
        expect(Base64.decode64(h[:base64_data])).to eq(png_data)
      end
    end

    it "raises error when conversion fails" do
      allow(described_class).to receive(:system).and_return(false)

      expect { described_class.pdf_to_png_base64(upload) }.to raise_error(/failed to convert pdf pages to images/)
    end
  end

  describe ".prepare_image" do
    let(:png_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }
    let(:gif_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "sunflower_websafe.gif")) }

    it "passes through images Bedrock supports, using the type detected from the bytes" do
      result = described_class.prepare_image(png_data)

      expect(result[:media_type]).to eq("image/png")
      expect(Base64.decode64(result[:base64_data])).to eq(png_data)
    end

    it 'works with GIFs' do
      result = described_class.prepare_image(gif_data)
      expect(result[:media_type]).to eq("image/gif")
    end

    it "converts image types Bedrock does not support to jpeg" do
      tiff_data = MiniMagick::Image.read(png_data).tap { |image| image.format("tiff") }.to_blob

      result = described_class.prepare_image(tiff_data)

      expect(result[:media_type]).to eq("image/jpeg")
      expect(Marcel::MimeType.for(StringIO.new(Base64.decode64(result[:base64_data])))).to eq("image/jpeg")
    end
  end

  describe ".ensure_safe_image_size" do
    let(:raw_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }

    it "raises for data that is not an image" do
      expect { described_class.ensure_safe_image_size("not-an-image") }.to raise_error(MiniMagick::Error)
    end
  end

  describe "compression and limits in processing" do
    let(:upload) { instance_double("ActiveStorageUpload") }
    let(:document) { instance_double("Document", upload: upload, document_type: "Employment") }

    before do
      allow(upload).to receive(:attached?).and_return(true)
      allow(described_class).to receive(:invoke_bedrock_model).and_return(
        double("Response", body: StringIO.new({ content: [{ type: "text", text: "}" }] }.to_json))
      )
    end

    context "with a very large image" do
      let(:large_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "over-4mb-image-IMG_OCT_20191005_150058.jpeg")) }

      it "shrinks images over the size limit" do
        shrunk_data = described_class.ensure_safe_image_size(large_data)

        expect(described_class.within_bedrock_limits?(shrunk_data)).to equal(true)
      end
    end

    context "with PDF with over 20 pages" do
      let(:doc_1) { create(:document, upload_path: Rails.root.join(
          "spec", "fixtures", "files", "document-with-25-pages.pdf")) }

      it "only takes the first 20 pages" do
        result = described_class.pdf_to_png_base64(doc_1.upload)
        expect(result.size).to eq(20)
      end
    end

    context "with a long PDF" do
      let!(:png_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }

      before do
        allow(upload).to receive(:content_type).and_return("application/pdf")
        allow(upload).to receive(:download).and_return("%PDF-1.4")
        allow(Dir).to receive(:mktmpdir).and_yield("/tmp/fake_dir")
        allow(described_class).to receive(:system).and_return(true)

        fake_pages = (1..25).map { |i| "/tmp/fake_dir/page-#{i}.png" }
        allow(Dir).to receive(:glob).and_return(fake_pages)
        allow(File).to receive(:binread).and_return(png_data)
      end
    end
  end

  describe "image dimension limits" do
    # Bedrock rejects any image with a side over 8000px, regardless of file size
    let(:bedrock_max_dimension) { 8000 }
    let(:upload) { instance_double("ActiveStorageUpload") }
    let(:document) { instance_double("Document", upload: upload, document_type: "Employment") }

    def generate_image(width, height, ext)
      Tempfile.create(["generated", ".#{ext}"]) do |file|
        MiniMagick.convert do |convert|
          convert.size "#{width}x#{height}"
          convert << "gradient:white-gray90"
          convert << file.path
        end
        File.binread(file.path)
      end
    end

    def sent_image_dimensions
      dimensions = []
      expect(described_class).to have_received(:invoke_bedrock_model) do |body|
        JSON.parse(body)["messages"][0]["content"].select { |c| c["type"] == "image" }.each do |image|
          dimensions << MiniMagick::Image.read(Base64.decode64(image["source"]["data"])).dimensions
        end
      end
      dimensions
    end

    before do
      allow(upload).to receive(:attached?).and_return(true)
      allow(described_class).to receive(:invoke_bedrock_model).and_return(
        double("Response", body: StringIO.new({ content: [{ type: "text", text: "}" }] }.to_json))
      )
    end

    [["image/png", "png"], ["image/jpeg", "jpg"]].each do |media_type, ext|
      context "with a #{ext} under the byte limit but taller than 8000px" do
        let(:raw_data) { generate_image(1170, 9000, ext) }

        before do
          allow(upload).to receive(:content_type).and_return(media_type)
          allow(upload).to receive(:download).and_return(raw_data)
        end

        it "resizes it to fit within Bedrock's dimension limit" do
          expect(raw_data.bytesize).to be < BedrockDocScreener::MAX_RAW_IMAGE_SIZE

          described_class.screen_document!(document: document)

          expect(sent_image_dimensions.flatten.max).to be <= bedrock_max_dimension
        end
      end
    end

    [[800, 600], [4032, 3024]].each do |width, height|
      context "with a #{width}x#{height} image already within limits" do
        let(:raw_data) { generate_image(width, height, "png") }

        before do
          allow(upload).to receive(:content_type).and_return("image/png")
          allow(upload).to receive(:download).and_return(raw_data)
        end

        it "sends the original bytes unchanged" do
          expect(raw_data.bytesize).to be < BedrockDocScreener::MAX_RAW_IMAGE_SIZE

          described_class.screen_document!(document: document)

          expect(described_class).to have_received(:invoke_bedrock_model) do |body|
            data = JSON.parse(body)["messages"][0]["content"][0]["source"]["data"]
            expect(Base64.decode64(data)).to eq(raw_data)
          end
        end
      end
    end

    context "with a PDF page that renders taller than 8000px" do
     # 50in tall page, rendered by pdftoppm at 200 DPI => 10000px
      let(:pdf_data) { create(:document, upload_path: Rails.root.join(
          "spec", "fixtures", "files", "really-tall-pdf.pdf")) }

      it "resizes the rendered page to fit within Bedrock's dimension limit" do
        described_class.screen_document!(document: pdf_data)
        expect(sent_image_dimensions.flatten.max).to be <= bedrock_max_dimension
      end
    end
  end
end
