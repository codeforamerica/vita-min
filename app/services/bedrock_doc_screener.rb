require 'aws-sdk-bedrockruntime'
require 'json'
require 'base64'
require "mini_magick"
require "tempfile"

module BedrockDocScreener
  MODEL_ID = 'us.anthropic.claude-haiku-4-5-20251001-v1:0'.freeze
  REGION = 'us-east-1'.freeze
  SUPPORTED_MEDIA_TYPES = %w[
    image/png
    image/jpeg
    application/pdf
  ].freeze

  PROMPT_VERSION = "v1".freeze

  def self.prompt_for(document_type:)
    <<~PROMPT
      Clients are uploading documents and you need to verify the validity of the document using these rules:
         1) If the photo is a poor quality image (poorly lit, blurry, cropped & missing information, pixelated screen etc.) 
            so much so that it renders the document illegible, then add "unreadable" to document_quality_issues array.
         2) If the document does not fit any of the doc types in the available-doc-types list,
            then set suggested_document_type=null and set matches_doc_type_verdict="fail".
            If the document seems to be a valid document, readable and the selected document type matches,
            then set document_quality_issues=["N/A"] and matches_doc_type_verdict="pass".
         3) If it does not appear to match the stated doc type (in this case #{document_type}) 
            but does match another type in the available-doc-types list, then set matches_doc_type_verdict="fail" 
            and set suggested_document_type to the key of the doc-type that matches.
            and include the doc-types that might be match in the explanation field by their label name.
         4) If the document is expired, then add "expired" to document_quality_issues array.
         5) If the document is fake ONLY if it is glaringly obvious (for example if it is labeled as 'SAMPLE', etc),
            then add "potentially_fake" to document_quality_issues array.
            Do not flag documents as potentially fake based on subtle concerns or suspicions.
         6) matches_doc_type_verdict should ONLY be determined by whether the document type matches, 
            not by document_quality_issues such as being expired, potentially fake, or unreadable.
            A document can pass the type match even if it has quality issues.
         7) If there is another reason that the document is not valid, then set document_quality_issues="other"
         8) Do not include any keys other than "matches_doc_type_verdict", "suggested_document_type", "document_quality_issues", "explanation" and "confidence"
         9) matches_doc_type_verdict should only be "pass" or "fail"
         10) Always set suggested_document_type to the key of the doc type that best matches the document.
            If none of the available doc types are a good fit, set suggested_document_type=null.
            Do not force a selection if there is no clear match.
         11) document_quality_issues is an array that can include: "unreadable", "expired", "potentially_fake", "other"
             Multiple issues can be present at the same time.
         12) "confidence" must be between 0.0 and 1.0. "confidence" must be one of these discrete values based on how clear the assessment is:
              - 0.95: Near-certain. The document clearly matches (or clearly does not match) the suggested document type with no ambiguity.
              - 0.8:  High confidence. Strong evidence supports your verification decision; unlikely to be wrong but not absolute.
              - 0.5:  Moderate confidence. The document probably is (or is not) the suggested type, but there are features that create uncertainty.
              - 0.2:  Low confidence. Verification is a best guess; the document has ambiguous characteristics that make it difficult to confirm or reject the suggested type.
      
      Document Type Guidelines:
      - IDs (like driver's licenses, state IDs, passports) are any documents that have a photo of the person, their name, 
        their birthday, and are issued by a state or federal government.

      available-doc-types: #{available_doc_types}

      Selected document type: #{document_type}

      Return ONLY valid JSON with this exact schema:
      {
        "matches_doc_type_verdict": "pass" | "fail",
        "suggested_document_type": "key from available-doc-types" | null,
        "document_quality_issues": ["unreadable" | "expired" | "potentially_fake" | "other"],
        "explanation": [Brief 1-2 sentence explanation of reason. Explain why invalid if so. The briefer the better, please do not be redundant.],
        "confidence": number between 0.0-1.0,
      }
    PROMPT
  end

  def self.available_doc_types
    # should always match @document_type_options in hub/document controller,
    # since those are the only types available in the drop down
    available_doc_types = [DocumentTypes::Identity, DocumentTypes::SsnItin] + (DocumentTypes::ALL_TYPES - DocumentTypes::IDENTITY_TYPES - DocumentTypes::SECONDARY_IDENTITY_TYPES)
    available_doc_types.map do |d|
      result = { key: d.key, label: d.label }
      result[:description] = d.description if d.respond_to?(:description)
      result
    end
  end

  def self.screen_document!(document:)
    raise "Document has no upload attached" unless document.upload.attached?

    media_type = document.upload.content_type
    raise "Unsupported media type: #{media_type}" unless SUPPORTED_MEDIA_TYPES.include?(media_type)

    input = if media_type == "application/pdf"
              pdf_to_png_base64(document.upload)
            else
              [{
                 media_type: media_type,
                 base64_data: Base64.strict_encode64(document.upload.download)
               }]
            end

    body_hash = construct_bedrock_payload(
      images: input,
      user_prompt: prompt_for(document_type: document.document_type)
    )

    response = invoke_bedrock_model(body_hash.to_json)

    raw_response_json = JSON.parse(response.body.read)
    generated_text = extract_text_from_response(raw_response_json)

    result_json = parse_strict_json!(generated_text)

    [result_json, raw_response_json]
  end

  def self.construct_bedrock_payload(images:, user_prompt:)
    {
      anthropic_version: "bedrock-2023-05-31",
      max_tokens: 250,
      messages: [{
                   role: "user",
                   content: [
                     *images.map do |img|
                       { type: "image", source: { type: "base64", media_type: img[:media_type], data: img[:base64_data] } }
                     end,
                     { type: "text", text: user_prompt }
                   ]
                 }]
    }
  end

  def self.invoke_bedrock_model(body_payload)
    client = Aws::BedrockRuntime::Client.new(region: REGION)
    client.invoke_model(
      body: body_payload,
      model_id: MODEL_ID,
      content_type: 'application/json',
      accept: 'application/json'
    )
  end

  def self.extract_text_from_response(response)
    Array(response['content'])
      .select { |content| content['type'] == 'text' }
      .map { |content| content['text'].to_s.strip }
      .reject(&:empty?)
      .join("\n")
  end

  def self.parse_strict_json!(text)
    s = text.to_s

    blocks = s.scan(/```(?:json)?\s*(\{.*?\})\s*```/m)
    if blocks.any?
      json_str = blocks.last.first
      return JSON.parse(json_str)
    end

    cleaned = s.strip
    cleaned = cleaned.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "").strip
    JSON.parse(cleaned)
  rescue JSON::ParserError => e
    raise "Bedrock did not return valid JSON. \n Error: #{e.message} \n Output: #{text.inspect}"
  end

  def self.pdf_to_png_base64(upload)
    images = []

    Tempfile.create(["upload", ".pdf"]) do |pdf|
      pdf.binmode
      pdf.write(upload.download)
      pdf.flush
      
      Dir.mktmpdir do |tmpdir|
        output_prefix = File.join(tmpdir, "page")
        success = system("pdftoppm", "-png", "-r", "200", pdf.path, output_prefix,
                         out: File::NULL, err: File::NULL)
        unless success
          raise "pdftoppm command failed with exit code #{$?.exitstatus}"
        end
        
        png_files = Dir.glob(File.join(tmpdir, "page-*.png")).sort_by do |f|
          File.basename(f)[/(\d+)\.png$/, 1].to_i
        end

        png_files.each do |png_path|
          data = File.binread(png_path)

          images << {
            media_type: "image/png",
            base64_data: Base64.strict_encode64(data)
          }
        end
      end
    end

    raise "pdf produced no pages" if images.empty?
    images
  rescue StandardError => e
    raise "failed to convert pdf pages to images (pdftoppm issue). #{e.class}: #{e.message}"
  end
end