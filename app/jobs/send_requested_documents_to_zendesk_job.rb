class SendRequestedDocumentsToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    with_raven_context(intake_context(intake)) do
      ensure_zendesk_ticket_on(intake)

      service = ZendeskFollowUpDocsService.new(intake)
      service.send_requested_docs
    end
  end
end
