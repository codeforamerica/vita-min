class SendSpouseAuthDocsToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    with_raven_context({ticket_id: intake.intake_ticket_id}) do
      if intake.completed_intake_sent_to_zendesk
        service = ZendeskIntakeService.new(intake)
        service.send_intake_pdf_with_spouse &&
          service.send_consent_pdf_with_spouse
      end
    end
  end
end
