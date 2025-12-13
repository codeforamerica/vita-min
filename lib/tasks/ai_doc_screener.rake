# frozen_string_literal: true
require 'aws-sdk-bedrockruntime'
require 'json'
require 'base64' # Required for Base64.strict_encode64

module BedrockDocumentScreener
  MODEL_ID = 'us.anthropic.claude-haiku-4-5-20251001-v1:0'
  REGION = 'us-east-1'
  MIME_TYPES = {
    '.pdf' => 'application/pdf',
    '.png' => 'image/png',
    '.jpg' => 'image/jpeg',
    '.jpeg' => 'image/jpeg'
  }.freeze
  DEFAULT_FILE_PATH = Rails.root.join("spec", "fixtures", "files", "picture_id.jpg").freeze
  DEFAULT_PROMPT = "Is this a photo id?"
  CLAUDE_MESSAGES_API_TEMPLATE = {
    anthropic_version: "bedrock-2023-05-31",
    max_tokens: 100,
    messages: [
      {
        role: "user",
        content: [
          {
            type: "image",
            source: {
              type: "base64",
              media_type: nil, # populated later
              data: nil # populated later
            }
          },
          {
            type: "text",
            text: DEFAULT_PROMPT
          }
        ]
      }
    ]
  }.freeze

  def self.file_media_type(file_path)
    media_type = MIME_TYPES[File.extname(file_path).downcase]
    raise "Unsupported file type: #{File.extname(file_path)}. Supported types: #{MIME_TYPES.keys.join(', ')}." unless media_type
    media_type
  end

  def self.file_data(file_path)
    base64_data = Base64.strict_encode64(File.binread(file_path))
    raise "Could not read and encode file: #{file_path}" unless base64_data
    base64_data
  end

  def self.construct_bedrock_payload(file_path)
    payload = CLAUDE_MESSAGES_API_TEMPLATE.deep_dup

    image_content = payload[:messages][0][:content]
    image_content[0][:source][:media_type] = file_media_type(file_path)
    image_content[0][:source][:data] = file_data(file_path)

    payload.to_json
  end

  # Invokes the AWS Bedrock model and returns the response object.
  def self.invoke_bedrock_model(body_payload)
    client = Aws::BedrockRuntime::Client.new(region: REGION)

    client.invoke_model(
      body: body_payload,
      model_id: MODEL_ID,
      content_type: 'application/json',
      accept: 'application/json'
    )
  end

  # Extracts the text content from a Bedrock Messages API response.
  def self.extract_text_from_response(response)
    response_body = JSON.parse(response.body.read)

    # this structure is specific to Claude 3 Messages API
    response_body['content']
      .select { |content| content['type'] == 'text' }
      .map { |content| content['text'] }
      .join("\n")
      .strip
  end

  # Logs the result of the screening process.
  def self.log_screening_result(file_path, user_prompt, generated_text, response_body)
    log_entry = <<~LOG
      --- Start Bedrock Log Entry ---
      Timestamp: #{Time.now}
      Model ID: #{MODEL_ID}
      Input File: #{file_path}
      Input Prompt: #{user_prompt}
      Raw Response: #{response_body}
      Generated Output:
      #{generated_text}
      --- End Bedrock Log Entry ---
    LOG

    puts log_entry
  end
end

namespace :ai_doc_screener do
  desc "Uses Amazon Bedrock to screen a document or piece of text against a set of criteria"
  task :screen_document, [:file_path, :user_prompt] => :environment do |t, args|
    file_path = args[:file_path] || BedrockDocumentScreener::DEFAULT_FILE_PATH
    user_prompt = args[:user_prompt] || BedrockDocumentScreener::DEFAULT_PROMPT

    puts "Invoking Bedrock model: #{BedrockDocumentScreener::MODEL_ID} for document analysis..."
    puts "Document: #{file_path}"
    puts "Prompt: '#{user_prompt}'"

    begin
      doc_data = BedrockDocumentScreener.prepare_doc_data_for_bedrock(file_path)
      body_payload = BedrockDocumentScreener.construct_bedrock_payload(doc_data, user_prompt)
      response = BedrockDocumentScreener.invoke_bedrock_model(body_payload)
      generated_text = BedrockDocumentScreener.extract_text_from_response(response)

      BedrockDocumentScreener.log_screening_result(file_path, user_prompt, generated_text, response)

    rescue Aws::BedrockRuntime::Errors::ServiceError => e
      puts "\n❌ Bedrock Service Error: #{e.message}"
    rescue StandardError => e
      puts "\n❌ Processing Error: #{e.message}"
    end
  end
end