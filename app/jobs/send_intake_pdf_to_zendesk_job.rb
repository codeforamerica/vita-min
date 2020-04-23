class SendIntakePdfToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    unless intake.intake_pdf_sent_to_zendesk
      service = ZendeskIntakeService.new(intake)
      output = service.send_preliminary_intake_and_consent_pdfs
      intake.update(intake_pdf_sent_to_zendesk: output)
    end
  end
end
