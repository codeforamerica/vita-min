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
      allow(upload).to receive(:content_type).and_return("text/plain")

      expect {
        described_class.screen_document!(document: document)
      }.to raise_error(BedrockDocScreener::UnsupportedMediaTypeError, "Unsupported media type: text/plain")
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

  describe ".prepare_image" do
    let(:png_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }

    it "passes through images Bedrock supports, using the type detected from the bytes" do
      result = described_class.prepare_image(png_data)

      expect(result[:media_type]).to eq("image/png")
      expect(Base64.decode64(result[:base64_data])).to eq(png_data)
    end

    it "converts image types Bedrock does not support to jpeg" do
      tiff_data = MiniMagick::Image.read(png_data).tap { |image| image.format("tiff") }.to_blob

      result = described_class.prepare_image(tiff_data)

      expect(result[:media_type]).to eq("image/jpeg")
      expect(Marcel::MimeType.for(StringIO.new(Base64.decode64(result[:base64_data])))).to eq("image/jpeg")
    end

    it "shrinks images over the size limit" do
      large_data = "A" * 4.megabytes
      allow(described_class).to receive(:ensure_safe_image_size).and_return("shrunk-data")

      result = described_class.prepare_image(large_data)

      expect(described_class).to have_received(:ensure_safe_image_size).with(large_data)
      expect(result).to eq(media_type: "image/jpeg", base64_data: Base64.strict_encode64("shrunk-data"))
    end
  end

  describe ".ensure_safe_image_size" do
    let(:raw_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }

    it "converts the image to jpeg" do
      result = described_class.ensure_safe_image_size(raw_data)

      expect(Marcel::MimeType.for(StringIO.new(result))).to eq("image/jpeg")
    end

    it "raises for data that is not an image" do
      expect { described_class.ensure_safe_image_size("not-an-image") }.to raise_error(MiniMagick::Error)
    end

    it "raises ImageTooLargeError when the image can't be shrunk under the limit" do
      stub_const("BedrockDocScreener::MAX_RAW_IMAGE_SIZE", 10)

      expect { described_class.ensure_safe_image_size(raw_data) }.to raise_error(BedrockDocScreener::ImageTooLargeError)
    end
  end

  describe ".prompt_for with page context" do
    it "includes the page context when given" do
      prompt = described_class.prompt_for(document_type: "Employment", page_context: "These images are pages 6-10 of a 14-page upload.\n")

      expect(prompt).to include("Selected document type: Employment\nThese images are pages 6-10 of a 14-page upload.\n\nReturn ONLY")
    end

    it "leaves the prompt unchanged without page context" do
      prompt = described_class.prompt_for(document_type: "Employment")

      expect(prompt).to include("Selected document type: Employment\n\nReturn ONLY")
    end
  end

  describe ".merge_chunk_results" do
    def chunk(verdict:, suggested:, issues:, confidence:, explanation: "chunk")
      {
        pages: [1],
        result: {
          "matches_doc_type_verdict" => verdict,
          "suggested_document_type" => suggested,
          "document_quality_issues" => issues,
          "explanation" => explanation,
          "confidence" => confidence
        }
      }
    end

    it "passes when any chunk matches the selected type, using the most confident passing chunk" do
      merged = described_class.merge_chunk_results([
                                                     chunk(verdict: "fail", suggested: "Receipts", issues: ["unreadable"], confidence: 0.95, explanation: "receipts"),
                                                     chunk(verdict: "pass", suggested: "Employment", issues: ["N/A"], confidence: 0.5, explanation: "maybe w2"),
                                                     chunk(verdict: "pass", suggested: "Employment", issues: ["expired"], confidence: 0.8, explanation: "w2")
                                                   ])

      expect(merged).to eq(
        "matches_doc_type_verdict" => "pass",
        "suggested_document_type" => "Employment",
        "document_quality_issues" => ["expired"],
        "explanation" => "w2",
        "confidence" => 0.8
      )
    end

    it "fails when no chunk matches, using the most confident chunk and every chunk's issues" do
      merged = described_class.merge_chunk_results([
                                                     chunk(verdict: "fail", suggested: "Receipts", issues: ["unreadable"], confidence: 0.5),
                                                     chunk(verdict: "fail", suggested: "Form1099INT", issues: ["N/A"], confidence: 0.95),
                                                     chunk(verdict: "fail", suggested: nil, issues: ["unreadable", "other"], confidence: 0.2)
                                                   ])

      expect(merged["matches_doc_type_verdict"]).to eq("fail")
      expect(merged["suggested_document_type"]).to eq("Form1099INT")
      expect(merged["confidence"]).to eq(0.95)
      expect(merged["document_quality_issues"]).to contain_exactly("unreadable", "other")
    end

    it "keeps N/A when no chunk found issues" do
      merged = described_class.merge_chunk_results([
                                                     chunk(verdict: "pass", suggested: "Employment", issues: ["N/A"], confidence: 0.95),
                                                     chunk(verdict: "pass", suggested: "Employment", issues: [], confidence: 0.8)
                                                   ])

      expect(merged["document_quality_issues"]).to eq(["N/A"])
    end
  end

  describe "screening a PDF" do
    let(:upload) { instance_double("ActiveStorageUpload") }
    let(:document) { instance_double("Document", upload: upload, document_type: "Employment") }
    let(:png_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "test-pattern.png")) }
    let(:total_pages) { 14 }
    let(:page_data) { ->(_page_number) { png_data } }
    let(:rendered_ranges) { [] }
    let(:bedrock_requests) { [] }
    let(:bedrock_result) { ->(_request) { { "matches_doc_type_verdict" => "pass", "suggested_document_type" => "Employment", "document_quality_issues" => ["N/A"], "explanation" => "ok", "confidence" => 0.95 } } }

    def bedrock_response(result)
      body = { "content" => [{ "type" => "text", "text" => result.to_json.delete_prefix("{") }], "stop_reason" => "end_turn" }
      double("Response", body: StringIO.new(body.to_json))
    end

    def image_count(request)
      request["messages"][0]["content"].count { |c| c["type"] == "image" }
    end

    def prompt(request)
      request["messages"][0]["content"].last["text"]
    end

    before do
      allow(upload).to receive(:attached?).and_return(true)
      allow(upload).to receive(:content_type).and_return("application/pdf")
      allow(upload).to receive(:download).and_return("%PDF-1.4")
      allow(described_class).to receive(:pdf_page_count).and_return(total_pages)
      allow(described_class).to receive(:system) do |*args, **|
        first_page = args[args.index("-f") + 1].to_i
        last_page = args[args.index("-l") + 1].to_i
        rendered_ranges << (first_page..last_page)
        (first_page..last_page).each { |n| File.binwrite("#{args.last}-#{n.to_s.rjust(2, "0")}.png", page_data.call(n)) }
        true
      end
      allow(described_class).to receive(:invoke_bedrock_model) do |body|
        request = JSON.parse(body)
        bedrock_requests << request
        bedrock_response(bedrock_result.call(request))
      end
    end

    it "sends every page in one request when they fit" do
      result_json, raw_response_json = described_class.screen_document!(document: document)

      expect(rendered_ranges).to eq([1..14])
      expect(bedrock_requests.map { |r| image_count(r) }).to eq([14])
      expect(prompt(bedrock_requests.first)).not_to include("These images are pages")

      expect(result_json).to include(
        "matches_doc_type_verdict" => "pass",
        "total_pages" => 14,
        "screened_pages" => (1..14).to_a,
        "page_limit_reached" => false,
        "skipped" => []
      )
      expect(result_json["chunks"].map { |c| c["pages"] }).to eq([(1..14).to_a])
      expect(raw_response_json["chunks"].size).to eq(1)
    end

    context "when the pages are over the request size limit" do
      before do
        stub_const("BedrockDocScreener::MAX_REQUEST_IMAGE_BYTES", Base64.strict_encode64(png_data).bytesize * 5)
      end

      it "splits them into as few requests as fit under the limit" do
        result_json, raw_response_json = described_class.screen_document!(document: document)

        expect(bedrock_requests.map { |r| image_count(r) }).to eq([5, 5, 4])
        expect(prompt(bedrock_requests[1])).to include("These images are pages 6-10 of a 14-page upload.")
        expect(result_json["screened_pages"]).to eq((1..14).to_a)
        expect(result_json["chunks"].map { |c| c["pages"] }).to eq([(1..5).to_a, (6..10).to_a, (11..14).to_a])
        expect(raw_response_json["chunks"].size).to eq(3)
      end
    end

    context "when there are more pages than images allowed per request" do
      before do
        stub_const("BedrockDocScreener::MAX_IMAGES_PER_REQUEST", 6)
      end

      it "splits them by image count" do
        described_class.screen_document!(document: document)

        expect(bedrock_requests.map { |r| image_count(r) }).to eq([6, 6, 2])
      end
    end

    context "when the selected document type is only in a later chunk" do
      before do
        stub_const("BedrockDocScreener::MAX_REQUEST_IMAGE_BYTES", Base64.strict_encode64(png_data).bytesize * 5)
      end

      let(:bedrock_result) do
        lambda do |request|
          if prompt(request).include?("pages 11-14")
            { "matches_doc_type_verdict" => "pass", "suggested_document_type" => "Employment", "document_quality_issues" => ["N/A"], "explanation" => "W-2 found", "confidence" => 0.8 }
          else
            { "matches_doc_type_verdict" => "fail", "suggested_document_type" => "Receipts", "document_quality_issues" => ["N/A"], "explanation" => "receipts", "confidence" => 0.95 }
          end
        end
      end

      it "merges the chunks into a passing result" do
        result_json, = described_class.screen_document!(document: document)

        expect(result_json).to include(
          "matches_doc_type_verdict" => "pass",
          "suggested_document_type" => "Employment",
          "explanation" => "W-2 found"
        )
      end

      it "tells each request what the earlier chunks were assessed as" do
        described_class.screen_document!(document: document)

        expect(prompt(bedrock_requests[0])).not_to include("Earlier pages of this upload")
        expect(prompt(bedrock_requests[1])).to include(
          "Earlier pages of this upload were already assessed:\n" \
          "- Pages 1-5: verdict=fail, suggested_document_type=Receipts, explanation: receipts\n" \
          "If the pages shown continue a document"
        )
        expect(prompt(bedrock_requests[2])).to include(
          "- Pages 1-5: verdict=fail, suggested_document_type=Receipts, explanation: receipts\n" \
          "- Pages 6-10: verdict=fail, suggested_document_type=Receipts, explanation: receipts\n"
        )
      end
    end

    context "with a single page PDF" do
      let(:total_pages) { 1 }

      it "sends one request without page context" do
        described_class.screen_document!(document: document)

        expect(bedrock_requests.size).to eq(1)
        expect(prompt(bedrock_requests.first)).not_to include("These images are pages")
      end
    end

    context "with a PDF longer than the page limit" do
      let(:total_pages) { 200 }

      it "only renders and screens up to the limit and records that it was hit" do
        result_json, = described_class.screen_document!(document: document)

        expect(rendered_ranges).to eq([1..BedrockDocScreener::MAX_SCREENED_PAGES])
        expect(bedrock_requests.map { |r| image_count(r) }).to eq([BedrockDocScreener::MAX_SCREENED_PAGES])
        expect(result_json).to include(
          "total_pages" => 200,
          "screened_pages" => (1..20).to_a,
          "page_limit_reached" => true
        )
      end
    end

    context "when a page is still too large after resizing" do
      let(:total_pages) { 3 }
      let(:large_page) { "A" * 4.megabytes }
      let(:page_data) { ->(n) { n == 2 ? large_page : png_data } }

      before do
        allow(described_class).to receive(:ensure_safe_image_size).and_call_original
        allow(described_class).to receive(:ensure_safe_image_size).with(large_page)
          .and_raise(BedrockDocScreener::ImageTooLargeError, "still too big")
      end

      it "tries to resize it, then skips it and screens the other pages" do
        result_json, = described_class.screen_document!(document: document)

        expect(described_class).to have_received(:ensure_safe_image_size).with(large_page)
        expect(image_count(bedrock_requests.first)).to eq(2)
        expect(result_json["screened_pages"]).to eq([1, 3])
        expect(result_json["skipped"]).to eq([{ "pages" => [2], "reason" => "BedrockDocScreener::ImageTooLargeError: still too big" }])
      end
    end

    context "when Bedrock rejects a request" do
      let(:total_pages) { 3 }
      let(:bad_page_data) { File.binread(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")) }
      let(:page_data) { ->(n) { n == 2 ? bad_page_data : png_data } }
      let(:bad_page_base64) { Base64.strict_encode64(bad_page_data) }

      before do
        allow(described_class).to receive(:invoke_bedrock_model) do |body|
          request = JSON.parse(body)
          bedrock_requests << request
          if request["messages"][0]["content"].any? { |c| c.dig("source", "data") == bad_page_base64 }
            raise Aws::BedrockRuntime::Errors::ValidationException.new(nil, "Could not process image")
          end
          bedrock_response(bedrock_result.call(request))
        end
      end

      it "retries it in halves and skips the page that still fails" do
        result_json, = described_class.screen_document!(document: document)

        expect(bedrock_requests.map { |r| image_count(r) }).to eq([3, 2, 1, 1, 1])
        expect(result_json["screened_pages"]).to eq([1, 3])
        expect(result_json["skipped"]).to eq([{ "pages" => [2], "reason" => "Aws::BedrockRuntime::Errors::ValidationException: Could not process image" }])
      end

      context "when every page fails" do
        let(:total_pages) { 1 }
        let(:page_data) { ->(_n) { bad_page_data } }

        it "raises the error" do
          expect {
            described_class.screen_document!(document: document)
          }.to raise_error(Aws::BedrockRuntime::Errors::ValidationException, "Could not process image")
        end
      end
    end

    context "when pdftoppm fails" do
      before do
        allow(described_class).to receive(:system).and_return(false)
      end

      it "raises" do
        expect {
          described_class.screen_document!(document: document)
        }.to raise_error(/failed to convert pdf pages to images/)
      end
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
      let(:large_data) { "A" * 4.megabytes }

      before do
        allow(upload).to receive(:content_type).and_return("image/jpeg")
        allow(upload).to receive(:download).and_return(large_data)
        allow(described_class).to receive(:ensure_safe_image_size).and_return("shrunk-data")
      end

      it "compresses the image before encoding" do
        described_class.screen_document!(document: document)
        expect(described_class).to have_received(:ensure_safe_image_size).with(large_data)
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
      before do
        allow(upload).to receive(:content_type).and_return("application/pdf")
        allow(upload).to receive(:download).and_return("%PDF-1.4")
        allow(described_class).to receive(:pdf_page_count).and_return(1)
        # Stand in for pdftoppm: write a tall rendered page where it would
        allow(described_class).to receive(:system) do |*args, **|
          output_prefix = args.last
          File.binwrite("#{output_prefix}-1.png", generate_image(1200, 9000, "png"))
          true
        end
      end

      it "resizes the rendered page to fit within Bedrock's dimension limit" do
        described_class.screen_document!(document: document)

        expect(sent_image_dimensions.flatten.max).to be <= bedrock_max_dimension
      end
    end
  end
end
