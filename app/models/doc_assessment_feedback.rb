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
end
