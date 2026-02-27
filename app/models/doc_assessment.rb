# == Schema Information
#
# Table name: doc_assessments
#
#  id                :bigint           not null, primary key
#  error             :text
#  prompt_version    :string           default("v1"), not null
#  raw_response_json :jsonb            not null
#  result_json       :jsonb            not null
#  status            :string           default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  document_id       :bigint           not null
#  input_blob_id     :bigint           not null
#  model_id          :string
#
# Indexes
#
#  index_doc_assessments_on_document_id  (document_id)
#
# Foreign Keys
#
#  fk_rails_...  (document_id => documents.id)
#
class DocAssessment < ApplicationRecord
  belongs_to :document
  has_many :feedbacks, class_name: "DocAssessmentFeedback", dependent: :destroy

  def matches_doc_type_verdict
    result_json&.dig("matches_doc_type_verdict")
  end

  def smart_scan_status
    verdict = matches_doc_type_verdict

    return "pass" if verdict == "pass"
    return "fail" if verdict.present?

    "attention"
  end

  def explanation
    result_json&.dig("explanation")
  end

  def suggested_document_type
    result_json&.dig("suggested_document_type")
  end
end
