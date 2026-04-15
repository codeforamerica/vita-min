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

  describe "callbacks" do
    describe "after_commit" do
      let(:document) { create(:document, document_type: DocumentTypes::SsnItin.key) }

      context "when feedback is correct and the suggested document type differs from the current document type" do
        let!(:doc_assessment) do
          create(
            :doc_assessment,
            document: document,
            result_json: {
              "suggested_document_type" => DocumentTypes::PrimaryIdentification::DriversLicense.key
            },
            raw_response_json: {}
          )
        end

        it "updates the document type to the suggested document type" do
          create(
            :doc_assessment_feedback,
            doc_assessment: doc_assessment,
            feedback: :correct
          )

          expect(document.reload.document_type).to eq(DocumentTypes::PrimaryIdentification::DriversLicense.key)
        end
      end

      context "when feedback is correct but the suggested document type matches the current document type" do
        let!(:doc_assessment) do
          create(
            :doc_assessment,
            document: document,
            result_json: {
              "suggested_document_type" => DocumentTypes::SsnItin.key
            },
            raw_response_json: {}
          )
        end

        it "does not change the document type" do
          expect {
            create(
              :doc_assessment_feedback,
              doc_assessment: doc_assessment,
              feedback: :correct
            )
          }.not_to change { document.reload.document_type }
        end
      end

      context "when feedback is incorrect" do
        let!(:doc_assessment) do
          create(
            :doc_assessment,
            document: document,
            result_json: {
              "suggested_document_type" => DocumentTypes::PrimaryIdentification::DriversLicense.key
            },
            raw_response_json: {}
          )
        end

        it "does not update the document type" do
          expect {
            create(
              :doc_assessment_feedback,
              doc_assessment: doc_assessment,
              feedback: :incorrect
            )
          }.not_to change { document.reload.document_type }
        end
      end
    end
  end
end
