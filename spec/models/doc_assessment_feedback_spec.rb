# frozen_string_literal: true

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
require "rails_helper"

RSpec.describe DocAssessmentFeedback, type: :model do
  describe "callbacks" do
    describe "after_commit" do
      let(:user) { create(:user) }
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
            user: user,
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
              user: user,
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
              user: user,
              feedback: :incorrect
            )
          }.not_to change { document.reload.document_type }
        end
      end
    end
  end
end
