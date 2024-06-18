class SendSurveyNotificationJob < ApplicationJob
  def perform(intake, submission)
    StateFile::MessagingService.new(
      intake: intake,
      submission: submission,
      message: StateFile::AutomatedMessage::SurveyNotification,
      body_args: { survey_link: StateFile::StateInformationService.survey_link(intake.state_code) } # TODO: test?
    ).send_message
  end

  def priority
    PRIORITY_LOW
  end
end
