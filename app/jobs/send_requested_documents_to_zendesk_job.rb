class SendRequestedDocumentsToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    service = ZendeskFollowUpDocsService.new(Intake.find(intake_id))
    service.send_requested_docs
  end
end
