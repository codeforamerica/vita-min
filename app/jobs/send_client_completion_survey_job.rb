class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      AutomatedMessage::CompletionSurvey
    )
  end
end
