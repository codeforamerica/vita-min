class SendClientInProgressMessageJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      SurveyMessages::InProgressMessage
    )
  end
end
