class SendCompletedIntakeToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    with_raven_context(intake_context(intake)) do
      ensure_zendesk_ticket_on(intake)

      service = ZendeskIntakeService.new(intake)

      sent_pdf = service.send_final_intake_pdf
      sent_docs = service.send_all_docs
      sent_bank_info = service.send_bank_details_png

      success = sent_pdf && sent_docs && sent_bank_info
      intake.update(completed_intake_sent_to_zendesk: success)
      raise 'Unable to send everything to Zendesk' unless success
    end
  end
end
