class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      SurveyMessages::GyrCompletionSurvey
    )
  end

  def priority
    PRIORITY_LOW
  end
end
