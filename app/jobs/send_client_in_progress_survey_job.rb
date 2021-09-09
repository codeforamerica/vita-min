class SendClientInProgressSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      :in_progress_survey_sent_at,
      AutomatedMessage::InProgressSurvey
    )
  end
end
