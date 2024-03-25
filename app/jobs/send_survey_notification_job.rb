class SendSurveyNotificationJob < ApplicationJob
  include StateFile::SurveyLinksConcern
  def perform(intake, submission)
    StateFile::MessagingService.new(
      intake: intake,
      submission: submission,
      message: StateFile::AutomatedMessage::SurveyNotification,
      body_args: { survey_link: survey_link(intake) }
    ).send_message
  end

  def priority
    PRIORITY_LOW
  end
end
