class SendClientInProgressMessageJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      AutomatedMessage::InProgress
    )
  end
end
