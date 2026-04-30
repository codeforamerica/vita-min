class AiScreenerMetricsService
  CACHE_KEY = 'AiScreenerMetricsService/payload'

  def self.call
    Rails.cache.fetch(CACHE_KEY, expires_in: 25.hours) do
      {
        client_classification_accuracy: client_classification_accuracy,
        ai_efficacy: ai_efficacy,
        most_common_wrong_ai_suggestions: most_common_wrong_ai_suggestions,
        most_common_document_types_ai_struggles_with: most_common_document_types_ai_struggles_with,
        ai_suggested_document_type_distribution: ai_suggested_document_type_distribution,
      }
    end
  end

  # Called by RefreshCachesJob
  def self.refresh_cache
    Rails.cache.delete(CACHE_KEY)
    self.call
  end

  private

  def self.scoped_documents
    Document.with_assessments.reorder(nil) # `reorder(nil)` needed for DISTINCT ON qy below.
  end

  def self.scoped_document_ids
    scoped_documents.select(:id)
  end

  def self.latest_assessments
    ids = DocAssessment
            .where(document_id: scoped_document_ids)
            .select("DISTINCT ON (document_id) id")
            .order("document_id, created_at DESC")
    DocAssessment.where(id: ids)
  end

  def self.feedback_for_latest_assessments
    DocAssessmentFeedback.where(doc_assessment_id: latest_assessments.select(:id))
  end

  def self.client_classification_accuracy
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

  def self.ai_efficacy
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

  def self.most_common_wrong_ai_suggestions(limit: 3)
    DocAssessment
      .where(id: incorrect_latest_assessment_ids)
      .where("result_json ->> 'suggested_document_type' IS NOT NULL")
      .group("result_json ->> 'suggested_document_type'")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def self.most_common_document_types_ai_struggles_with(limit: 3)
    scoped_documents
      .joins(:assessments)
      .where(doc_assessments: { id: incorrect_latest_assessment_ids })
      .group("documents.document_type")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def self.incorrect_latest_assessment_ids
    feedback_for_latest_assessments
      .where(feedback: :incorrect)
      .select(:doc_assessment_id)
  end

  def self.ai_suggested_document_type_distribution(limit: 20)
    latest_assessments
      .where("result_json ->> 'suggested_document_type' IS NOT NULL")
      .group("result_json ->> 'suggested_document_type'")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(limit)
      .count
  end

  def self.percent(numerator, denominator)
    return 0.0 if denominator.to_i.zero?
    numerator.to_f / denominator.to_f
  end
end
