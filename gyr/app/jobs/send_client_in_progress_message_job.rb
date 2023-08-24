class SendClientInProgressMessageJob < ApplicationJob
  def perform(client)
    SurveySender.send_survey(
      client,
      AutomatedMessage::InProgress
    )
  end

  def priority
    PRIORITY_LOW
  end
end
