class DocScreenerJob < ApplicationJob
  PROMPT_VERSION = "v1".freeze

  def perform(document_id)
    document = Document.find(document_id)
    return unless document.upload.attached?

    assessment = DocAssessment.find_or_create_by!(
      document_id: document.id,
      prompt_version: PROMPT_VERSION,
      input_blob_id: document.upload.blob_id
    )

    return if assessment.status == "complete"

    assessment.update!(
      status: "processing",
      model_id: BedrockDocScreener::MODEL_ID,
      error: nil
    )

    result_json, raw_response_json = BedrockDocScreener.screen_document!(document: document)

    assessment.update!(
      status: "complete",
      result_json: result_json,
      raw_response_json: raw_response_json
    )
  rescue ActiveRecord::RecordNotUnique
    retry
  rescue => e
    assessment&.update!(
      status: "failed",
      error: "#{e.class}: #{e.message}"
    )
    raise
  end

  def priority
    PRIORITY_LOW
  end
end