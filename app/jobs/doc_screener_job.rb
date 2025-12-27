class DocScreenerJob < ApplicationJob
  def perform(document_id)
    return if Flipper.enabled?(:disable_ai_doc_screener)

    document = Document.find(document_id)
    return unless document.upload.attached?

    assessment = DocAssessment.find_or_create_by!(
      document_id: document.id,
      prompt_version: BedrockDocScreener::PROMPT_VERSION,
      input_blob_id: document.upload.blob_id
    )

    if assessment.status == "complete"
      assessment = DocAssessment.create!(
        document_id: document.id,
        prompt_version: BedrockDocScreener::PROMPT_VERSION,
        input_blob_id: document.upload.blob_id
      )
    end

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