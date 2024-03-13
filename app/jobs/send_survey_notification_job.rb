class SendSurveyNotificationJob < ApplicationJob
  def perform(intake, submission)
    StateFile::MessagingService.new(
      intake: intake,
      submission: submission,
      message: StateFile::AutomatedMessage::SurveyNotification,
      body_args: { survey_link: survey_link }).send_message
  end

  def priority
    PRIORITY_LOW
  end

  private
  def survey_link
    case @intake.state_code
    when 'ny'
      'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu'
    when 'az'
      'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey'
    else
      ''
    end
  end

  # SendSurveyNotificationJob.set(wait_until: 15.seconds.from_now).perform_later
  # SendSurveyNotificationJob.set(wait_until: 15.seconds.from_now).perform_later()
end
