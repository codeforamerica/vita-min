class AiScreenerMetricsService
  def initialize(document_scope: Document.with_assessments)
    @document_scope = document_scope
  end

  def call
    {
      client_classification_accuracy: client_classification_accuracy,
      ai_efficacy: ai_efficacy,
      most_common_wrong_ai_suggestions: most_common_wrong_ai_suggestions,
      most_common_document_types_ai_struggles_with: most_common_document_types_ai_struggles_with,
      ai_suggested_document_type_distribution: ai_suggested_document_type_distribution,
    }
  end

  private

  attr_reader :document_scope

  def unscoped_document_scope
    @unscoped_document_scope ||= document_scope.reorder(nil)
  end

  def scoped_document_ids
    unscoped_document_scope.select(:id)
  end

  def latest_assessments
    @latest_assessments ||= begin
                              ids = DocAssessment
                                      .where(document_id: scoped_document_ids)
                                      .select("DISTINCT ON (document_id) id")
                                      .order("document_id, created_at DESC")

                              DocAssessment.where(id: ids)
                            end
  end

  def feedback_for_latest_assessments
    @feedback_for_latest_assessments ||= DocAssessmentFeedback
                                           .where(doc_assessment_id: latest_assessments.select(:id))
  end

  def client_classification_accuracy
    total = latest_assessments.count

    pass_count = latest_assessments
                   .where("result_json ->> 'matches_doc_type_verdict' = 'pass'")
                   .count

    fail_count = latest_assessments
                   .where("result_json ->> 'matches_doc_type_verdict' IS NOT NULL")
                   .where.not("result_json ->> 'matches_doc_type_verdict' = 'pass'")
                   .count

    undetermined_count = latest_assessments
                           .where("result_json ->> 'matches_doc_type_verdict' IS NULL")
                           .count

    {
      total: total,
      pass: pass_count,
      fail: fail_count,
      undetermined: undetermined_count,
      pass_percent: percent(pass_count, total),
      fail_percent: percent(fail_count, total),
      undetermined_percent: percent(undetermined_count, total)
    }
  end

  def ai_efficacy
    counts = feedback_for_latest_assessments
               .where(feedback: %i[correct incorrect])
               .group(:feedback)
               .count

    correct = counts["correct"].to_i
    incorrect = counts["incorrect"].to_i
    total = correct + incorrect

    {
      total_feedback: total,
      correct: correct,
      incorrect: incorrect,
      correct_percent: percent(correct, total),
      incorrect_percent: percent(incorrect, total)
    }
  end

  def most_common_wrong_ai_suggestions(limit: 3)
    DocAssessment
      .where(id: incorrect_latest_assessment_ids)
      .where("result_json ->> 'suggested_document_type' IS NOT NULL")
      .group("result_json ->> 'suggested_document_type'")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def most_common_document_types_ai_struggles_with(limit: 3)
    unscoped_document_scope
      .joins(:assessments)
      .where(doc_assessments: { id: incorrect_latest_assessment_ids })
      .group("documents.document_type")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def incorrect_latest_assessment_ids
    feedback_for_latest_assessments
      .where(feedback: :incorrect)
      .select(:doc_assessment_id)
  end

  def ai_suggested_document_type_distribution(limit: 20)
    latest_assessments
      .where("result_json ->> 'suggested_document_type' IS NOT NULL")
      .group("result_json ->> 'suggested_document_type'")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def percent(numerator, denominator)
    return 0.0 if denominator.to_i.zero?
    numerator.to_f / denominator.to_f
  end
end