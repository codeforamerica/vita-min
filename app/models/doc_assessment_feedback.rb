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

  after_commit :post_processing

  private

  def post_processing
    update_document_display_name if feedback_correct?
  end

  def update_document_display_name
    doc = doc_assessment.document
    name = doc.document_type
    tally = Document.where({intake_id: doc.intake_id,
                            document_type: doc.document_type}).count
    if tally > 1
      name += ' ' + tally.to_s
    end
    doc.update!(display_name: name)
  end
end
