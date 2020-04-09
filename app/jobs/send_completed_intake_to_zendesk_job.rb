class SendCompletedIntakeToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)

    service = ZendeskIntakeService.new(intake)
    success = service.send_final_intake_pdf &&
      service.send_consent_pdf &&
      service.send_all_docs &&
      service.send_additional_info_document

    intake.update(completed_intake_sent_to_zendesk: success)
  end
end
