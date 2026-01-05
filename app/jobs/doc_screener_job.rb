class DocScreenerJob < ApplicationJob
  def perform(document_id)
    return if Flipper.enabled?(:disable_ai_doc_screener)

    document = Document.find(document_id)
    return unless document.upload.attached?

    assessment = find_or_create_assessment_for(document)

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

  private

  def find_or_create_assessment_for(document)
    attrs = {
      document_id: document.id,
      prompt_version: BedrockDocScreener::PROMPT_VERSION,
      input_blob_id: document.upload.blob_id
    }

    DocAssessment.transaction do
      assessment = DocAssessment.lock.find_by(attrs)
      if assessment.nil? || assessment.status == "complete"
        assessment = DocAssessment.create!(attrs)
      end
      assessment
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
