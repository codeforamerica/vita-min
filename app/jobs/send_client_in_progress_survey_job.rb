class SendClientInProgressSurveyJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      AutomatedMessage::InProgressSurvey
    )
  end
end
