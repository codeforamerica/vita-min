class SendCompletedIntakeToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    with_raven_context({ticket_id: intake.intake_ticket_id}) do
      service = ZendeskIntakeService.new(intake)
      success = service.send_final_intake_pdf &&
          service.send_bank_details_png &&
          service.send_all_docs

      intake.update(completed_intake_sent_to_zendesk: success)
    end
  end
end
