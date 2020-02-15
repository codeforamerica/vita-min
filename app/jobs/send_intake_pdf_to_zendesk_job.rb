class SendIntakePdfToZendeskJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    intake = Intake.find(intake_id)
    unless intake.intake_pdf_sent_to_zendesk
      service = ZendeskIntakeService.new(intake)
      output = service.send_intake_pdf
      intake.update(intake_pdf_sent_to_zendesk: output)
    end
  end
end
