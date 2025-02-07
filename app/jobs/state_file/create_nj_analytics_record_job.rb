module StateFile
  class CreateNjAnalyticsRecordJob < ApplicationJob
    def perform(submission_id)
      submission = EfileSubmission.find(submission_id)
      nj_analytics = submission.data_source.create_state_file_nj_analytics!
      nj_analytics&.update(nj_analytics.calculated_fields)
    end

    def priority
      PRIORITY_LOW
    end
  end
end
