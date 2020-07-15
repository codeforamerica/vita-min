class SendRequestedDocumentsToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    with_raven_context(intake_context(intake)) do
      ensure_zendesk_ticket_on(intake)

      service = ZendeskFollowUpDocsService.new(intake)
      service.send_requested_docs

      intake.client_efforts.create(effort_type: :uploaded_requested_docs, ticket_id: intake.intake_ticket_id, made_at: Time.now)
    end
  end
end
