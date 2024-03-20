module Efile
  class SendSurveyNotificationsService
    include StateFile::SurveyLinksConcern
    BATCH_SIZE = 5

    def run
      accepted_submissions = EfileSubmission.joins(:efile_submission_transitions)
                                            .where("efile_submission_transitions.to_state = 'accepted'")
                                            .where.not("message_tracker #> '{messages.state_file.survey_notification}' IS NOT NULL")

      accepted_submissions.each_slice(BATCH_SIZE) do |batch|
        batch.each do |submission|
          puts "Sending survey notification to #{submission.id}"
          StateFile::MessagingService.new(
            intake: submission.data_source,
            submission: submission,
            message: StateFile::AutomatedMessage::SurveyNotification,
            body_args: { survey_link: survey_link(submission.data_source) }
          ).send_message
        end
      end
    end
  end
end
