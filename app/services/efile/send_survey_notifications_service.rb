module Efile
  class SendSurveyNotificationsService
    BATCH_SIZE = 5
    def self.run
      accepted_submissions = EfileSubmission.joins(:efile_submission_transitions)
                                            .where("efile_submission_transitions.to_state = 'accepted'")
                                            .where.not("message_tracker #> '{messages.state_file.survey_notification}' IS NOT NULL")

      accepted_submissions.each_slice(BATCH_SIZE) do |batch|
        batch.each do |submission|
          StateFile::MessagingService.new(
            intake: submission.data_source,
            submission: submission,
            message: StateFile::AutomatedMessage::SurveyNotification,
            body_args: { survey_link: survey_link(submission.data_source) }
          ).send_message
        end
      end
    end

    # TODO | Make concern for these links
    private
    def survey_link(intake)
      case intake.state_code
      when 'ny'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu'
      when 'az'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey'
      else
        ''
      end
    end
  end
end