class SendRequestedDocumentsToZendeskJob < ApplicationJob
  queue_as :default
  retry_on ZendeskIntakeService::MissingTicketError, wait: 1.minute

  def perform(intake_id)
    intake = Intake.find(intake_id)

    with_raven_context({intake_id: intake.id, ticket_id: intake.intake_ticket_id}) do
      ensure_zendesk_ticket_on(intake)

      service = ZendeskFollowUpDocsService.new(intake)
      service.send_requested_docs
    end
  end
end
