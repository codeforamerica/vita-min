class SendIntakePdfToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    return if intake.intake_pdf_sent_to_zendesk

    with_raven_context(intake_context(intake)) do
      ensure_zendesk_ticket_on(intake)

      service = ZendeskIntakeService.new(intake)
      output = service.send_preliminary_intake_and_consent_pdfs
      intake.update(intake_pdf_sent_to_zendesk: output)

      intake.client_efforts.create(effort_type: :completed_intake_questions, ticket_id: intake.intake_ticket_id, made_at: Time.now)
    end
  end
end
