class SendEipIntakeConsentToZendeskJob < ZendeskJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    with_raven_context(intake_context(intake)) do
      service = Zendesk::EipService.new(intake)
      service.send_consent_to_zendesk
    end
  end
end
