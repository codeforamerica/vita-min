module StateFile
  class CreateNjAnalyticsRecordJob < ApplicationJob
    def perform(submission_id)
      submission = EfileSubmission.find(submission_id)
      nj_analytics = StateFileNjAnalytics.create(state_file_nj_intake: submission.data_source)
      nj_analytics&.update(nj_analytics.calculated_fields)
    end

    def priority
      PRIORITY_LOW
    end
  end
end
