# == Schema Information
#
# Table name: doc_assessment_feedbacks
#
#  id                :bigint           not null, primary key
#  feedback          :integer          default("unfilled"), not null
#  feedback_notes    :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  doc_assessment_id :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_doc_assessment_feedbacks_on_doc_assessment_id  (doc_assessment_id)
#  index_doc_assessment_feedbacks_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (doc_assessment_id => doc_assessments.id)
#  fk_rails_...  (user_id => users.id)
#
class DocAssessmentFeedback < ApplicationRecord
  belongs_to :doc_assessment
  belongs_to :user

  enum feedback: { unfilled: 0, correct: 1, incorrect: 2 }, _prefix: :feedback

  validates :feedback, presence: true

  after_commit :update_document_type_from_confirmed_assessment, on: :create

  private

  def update_document_type_from_confirmed_assessment
    return unless feedback_correct?

    assessment = doc_assessment
    suggested_type = assessment.suggested_document_type
    document = assessment.document

    return if suggested_type.blank?
    return if suggested_type == document.document_type
    return unless valid_document_type?(suggested_type)

    document.skip_screener_rerun = true
    document.update!(document_type: suggested_type)
  end

  def valid_document_type?(document_type)
    DocumentTypes::ALL_TYPES.map(&:key).include?(document_type)
  end
end
