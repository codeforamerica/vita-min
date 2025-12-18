require 'aws-sdk-bedrockruntime'
require 'json'
require 'base64'

module BedrockDocScreener
  MODEL_ID = 'us.anthropic.claude-haiku-4-5-20251001-v1:0'.freeze
  REGION = 'us-east-1'.freeze
  SUPPORTED_MEDIA_TYPES = %w[
    image/png
    image/jpeg
  ].freeze
  # since the payload is `type: "image"` it won't work for application/pdf
  # can convert the pdf to image or use another bedrock flow for docs

  # Update the prompt version if you are updating the prompt
  PROMPT_VERSION = "v1".freeze
  def self.prompt_for(document_type:)
    <<~PROMPT
      You are validating an uploaded client document.

      Document type: #{document_type}

      Return ONLY valid JSON with this exact schema:

      {
        "verdict": "pass" | "fail" | "needs_review",
        "reasons": [string, brief explanation],
        "confidence": number between 0.0-1.0,
      }

      Rules:
      - If the document is unreadable, set verdict="needs_review" and include reason "unreadable".
      - If it does not appear to match the stated document type, verdict="fail" and include reason "wrong_document_type".
      - If it appears valid and readable, verdict="pass".
      - "confidence" must be between 0.0 and 1.0.
      - Do not include any keys other than verdict, reasons and confidence
    PROMPT
  end

  def self.screen_document!(document:)
    raise "Document has no upload attached" unless document.upload.attached?

    media_type = document.upload.content_type
    raise "Unsupported media type: #{media_type}" unless SUPPORTED_MEDIA_TYPES.include?(media_type)

    base64_data = Base64.strict_encode64(document.upload.download)

    body_hash = construct_bedrock_payload(
      base64_data: base64_data,
      media_type: media_type,
      user_prompt: prompt_for(document_type: document.document_type)
    )

    response = invoke_bedrock_model(body_hash.to_json)

    raw_response_json = JSON.parse(response.body.read)
    generated_text = extract_text_from_response(raw_response_json)

    result_json = parse_strict_json!(generated_text)

    [result_json, raw_response_json]
  end

  def self.construct_bedrock_payload(base64_data:, media_type:, user_prompt:)
    {
      anthropic_version: 'bedrock-2023-05-31',
      max_tokens: 250,
      messages: [{
                   role: 'user',
                   content: [
                     { type: 'image', source: { type: 'base64', media_type: media_type, data: base64_data } },
                     { type: 'text', text: user_prompt }
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
      .map { |content| content['text'] }
      .join('\n')
      .strip
  end

  def self.parse_strict_json!(text)
    cleaned = text.to_s.strip

    cleaned = cleaned.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "").strip

    JSON.parse(cleaned)
  rescue JSON::ParserError => e
    raise "Model did not return valid JSON. Error=#{e.message}. Output=#{text.inspect}"
  end
end