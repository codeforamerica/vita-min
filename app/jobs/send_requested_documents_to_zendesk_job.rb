class SendRequestedDocumentsToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    with_raven_context({ticket_id: intake.intake_ticket_id}) do
      service = ZendeskFollowUpDocsService.new(intake)
      service.send_requested_docs
    end
  end
end
