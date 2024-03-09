module StateFile
  class SendStillProcessingNoticeJob < ApplicationJob
    def perform(submission)
      return if submission.data_source.efile_submissions.any? { |sub| ["rejected", "accepted"].include?(sub.current_state) }

      StateFile::AfterTransitionMessagingService.new(submission).send_efile_submission_still_processing_message
    end

    def priority
      PRIORITY_LOW
    end
  end
end
