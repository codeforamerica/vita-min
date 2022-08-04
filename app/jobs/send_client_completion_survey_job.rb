class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      SurveyMessages::GyrCompletionSurvey
    )
  end
end
