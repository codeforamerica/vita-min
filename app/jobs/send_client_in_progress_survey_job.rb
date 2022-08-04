class SendClientInProgressSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      SurveyMessages::GyrInProgressSurvey
    )
  end
end
