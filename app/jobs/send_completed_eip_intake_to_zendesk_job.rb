class SendCompletedEipIntakeToZendeskJob < ZendeskJob
  queue_as :default

  def perform(intake_id)
    Zendesk::EipService.new(Intake.find(intake_id)).send_completed_intake_to_zendesk
  end
end
