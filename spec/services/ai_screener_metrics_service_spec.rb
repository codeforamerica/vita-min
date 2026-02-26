require "rails_helper"

RSpec.describe AiScreenerMetricsService do
  describe "#call" do
    def create_assessment(document:, created_at:, verdict:, suggested_type: nil)
      create(
        :doc_assessment,
        document: document,
        created_at: created_at,
        result_json: {
          "matches_doc_type_verdict" => verdict,
          "suggested_document_type" => suggested_type
        }
      )
    end

    def create_feedback(assessment:, feedback:)
      create(:doc_assessment_feedback, doc_assessment: assessment, feedback: feedback)
    end

    let(:w2_key) { DocumentTypes::SecondaryIdentification::W2.key }
    let(:form1099_key) { DocumentTypes::SecondaryIdentification::Form1099.key }
    let(:passport_key) { DocumentTypes::PrimaryIdentification::Passport.key }

    it "returns expected metrics using only the latest assessment per document" do
      doc1 = create(:document, document_type: w2_key)
      doc2 = create(:document, document_type: form1099_key)
      doc3 = create(:document, document_type: passport_key)

      older_doc1 = create_assessment(
        document: doc1,
        created_at: 2.days.ago,
        verdict: "fail",
        suggested_type: w2_key
      )
      latest_doc1 = create_assessment(
        document: doc1,
        created_at: 1.day.ago,
        verdict: "pass",
        suggested_type: w2_key
      )

      latest_doc2 = create_assessment(
        document: doc2,
        created_at: 1.day.ago,
        verdict: "fail",
        suggested_type: form1099_key
      )

      latest_doc3 = create_assessment(
        document: doc3,
        created_at: 1.day.ago,
        verdict: nil,
        suggested_type: nil
      )

      create_feedback(assessment: latest_doc1, feedback: :correct)
      create_feedback(assessment: latest_doc2, feedback: :incorrect)

      create_feedback(assessment: older_doc1, feedback: :incorrect)

      result = described_class.new.call

      expect(result[:client_classification_accuracy]).to include(
                                                           total: 3,
                                                           pass: 1,
                                                           fail: 1,
                                                           undetermined: 1
                                                         )

      expect(result[:ai_efficacy]).to include(
                                        total_feedback: 2,
                                        correct: 1,
                                        incorrect: 1
                                      )

      expect(result[:ai_classification_accuracy]).to include(
                                                       total_feedback: 2,
                                                       correct: 1,
                                                       incorrect: 1
                                                     )

      expect(result[:most_common_wrong_ai_suggestions]).to eq({ form1099_key => 1 })
      expect(result[:most_common_document_types_ai_struggles_with]).to eq({ form1099_key => 1 })

      expect(result[:ai_suggested_document_type_distribution]).to eq(
                                                                    { form1099_key => 1, w2_key => 1 }
                                                                  )
    end

    it "handles the case where there are no assessments" do
      result = described_class.new.call

      expect(result[:client_classification_accuracy]).to include(
                                                           total: 0,
                                                           pass: 0,
                                                           fail: 0,
                                                           undetermined: 0,
                                                           pass_pct: 0.0,
                                                           fail_pct: 0.0,
                                                           undetermined_pct: 0.0
                                                         )

      expect(result[:ai_efficacy]).to include(
                                        total_feedback: 0,
                                        correct: 0,
                                        incorrect: 0,
                                        correct_pct: 0.0,
                                        incorrect_pct: 0.0
                                      )

      expect(result[:most_common_wrong_ai_suggestions]).to eq({})
      expect(result[:most_common_document_types_ai_struggles_with]).to eq({})
      expect(result[:ai_suggested_document_type_distribution]).to eq({})
    end

    it "filters by document_scope" do
      included_doc = create(:document, document_type: w2_key)
      excluded_doc = create(:document, document_type: form1099_key)

      included_assessment = create_assessment(
        document: included_doc,
        created_at: 1.day.ago,
        verdict: "fail",
        suggested_type: w2_key
      )
      excluded_assessment = create_assessment(
        document: excluded_doc,
        created_at: 1.day.ago,
        verdict: "pass",
        suggested_type: form1099_key
      )

      create_feedback(assessment: included_assessment, feedback: :incorrect)
      create_feedback(assessment: excluded_assessment, feedback: :correct)

      scoped_service = described_class.new(document_scope: Document.where(id: included_doc.id))
      result = scoped_service.call

      expect(result[:client_classification_accuracy]).to include(
                                                           total: 1,
                                                           pass: 0,
                                                           fail: 1,
                                                           undetermined: 0
                                                         )

      expect(result[:ai_efficacy]).to include(
                                        total_feedback: 1,
                                        correct: 0,
                                        incorrect: 1
                                      )

      expect(result[:most_common_wrong_ai_suggestions]).to eq({ w2_key => 1 })
      expect(result[:most_common_document_types_ai_struggles_with]).to eq({ w2_key => 1 })
      expect(result[:ai_suggested_document_type_distribution]).to eq({ w2_key => 1 })
    end
  end
end