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
            so much so that it renders the document illegible, 
            then set reason="unreadable" and set verdict="fail".
         2) If the document does not fit any of the doc types in the available-doc-types list,
            then set reason="no_doc_type_match" and set verdict="fail".
         3) If it does not appear to match the stated doc type (in this case #{document_type}) 
            but does match another type in the available-doc-types list,
            then set reason="wrong_document_type", verdict="fail" 
            and include the doc-types that might be match in the explanation field by their label name.
         4) If the document is expired, then set reason="expired" and verdict="fail".
         5) If the document is fake (for example if it is labeled as a 'sample'),
            then set reason="fake" and verdict="fail".
         6) If there is another reason that the document is not valid, 
            then set reason="other" and verdict="fail".
         7) If the document seems to be a valid document, readable and the selected document type matches,
            then set reason="" and verdict="pass".
         8) "confidence" must be between 0.0 and 1.0.
         9) Do not include any keys other than "verdict", "reason", "explanation" and "confidence"
         10) verdict should only be "pass" or "fail"
      
      available-doc-types: #{available_doc_types}

      Selected document type: #{document_type}

      Return ONLY valid JSON with this exact schema:
      {
        "verdict": "pass" | "fail",
        "reason": "unreadable" | "no_doc_type_match" | "wrong_document_type" | expired" | "fake" | "other",
        "explanation": [Brief 1-2 sentence explanation of reason. Explain why invalid if so. The briefer the better, please do not be redundant.],
        "confidence": number between 0.0-1.0,
      }
    PROMPT
  end

  def self.available_doc_types
    # should always match @document_type_options in hub/document controller,
    # since those are the only types available in the drop down
    available_doc_types = [DocumentTypes::Identity, DocumentTypes::SsnItin] + (DocumentTypes::ALL_TYPES - DocumentTypes::IDENTITY_TYPES - DocumentTypes::SECONDARY_IDENTITY_TYPES)
    available_doc_types.map { |d| {key: d.key, label: d.label} }
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

      MiniMagick::Image.open(pdf.path).pages.each_with_index do |page, index|
        Tempfile.create(["pdf_page_#{index}", ".png"]) do |png|
          MiniMagick::Tool::Convert.new do |convert|
            convert.density(200)
            convert.quality(90)
            convert << "#{pdf.path}[#{index}]"
            convert << png.path
          end

          data = File.binread(png.path)

          images << {
            media_type: "image/png",
            base64_data: Base64.strict_encode64(data)
          }
        end
      end
    end

    raise "pdf produced no pages" if images.empty?
    images
  rescue MiniMagick::Error, MiniMagick::Invalid => e
    raise "failed to convert pdf pages to images (perhaps minimagick or ghostscript issue). #{e.class}: #{e.message}"
  end
end