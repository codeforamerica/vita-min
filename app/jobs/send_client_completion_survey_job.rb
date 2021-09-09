class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      :completion_survey_sent_at,
      AutomatedMessage::CompletionSurvey
    )
  end
end
