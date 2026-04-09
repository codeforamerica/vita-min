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
require 'rails_helper'

shared_context 'doc_1' do
 let!(:document) { 
    create(:document, intake_id: 2814, display_name: 'broccoli') }
  let!(:doc_assessment) {
    create(:doc_assessment, document: document,
           result_json: {suggested_document_type: 'Passport'}) }
  let!(:doc_assessment_feedback) {
    create(:doc_assessment_feedback, doc_assessment: doc_assessment) }
end

shared_context 'doc_2' do
  let!(:document_2) {
    create(:document, intake_id: 2814, display_name: 'spinach') }
  let!(:doc_assessment_2) { 
      create(:doc_assessment, document: document_2,
              result_json: {suggested_document_type: 'Passport'}) }
  let!(:doc_assessment_feedback_2) {
    create(:doc_assessment_feedback, doc_assessment: doc_assessment_2) }
end

RSpec.describe DocAssessmentFeedback do
  describe 'post_processing' do
    context 'when feedback is correct' do
      include_context 'doc_1'
      it 'updates the display_name' do
        doc_assessment_feedback.update!(feedback: :correct)
        expect(document.reload.display_name).to eq('Passport')
      end
    end

    context 'when feedback is correct and there are more than one of this display_name for this intake' do
      include_context 'doc_1'
      include_context 'doc_2'
      it 'updates the display_name which includes a numeric suffix' do
        doc_assessment_feedback.update!(feedback: :correct)
        doc_assessment_feedback_2.update!(feedback: :correct)
        expect(document_2.reload.display_name).to eq('Passport 2')
      end
    end
  end
end
