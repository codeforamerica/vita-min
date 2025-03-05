module StateFile
  class SendSurveyNotificationJob < ApplicationJob
    def perform(intake, submission)
      return if submission.data_source.efile_submissions.any? { |sub| sub.current_state == "cancelled" }

      StateFile::MessagingService.new(
        intake: intake,
        submission: submission,
        message: StateFile::AutomatedMessage::SurveyNotification,
        body_args: { survey_link: StateFile::StateInformationService.survey_link(intake.state_code) }
      ).send_message
    end

    def priority
      PRIORITY_LOW
    end
  end
end
