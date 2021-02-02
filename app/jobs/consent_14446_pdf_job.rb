class Consent14446PdfJob < ApplicationJob
  def perform(intake_id)
    Intake.find(intake_id).create_consent_document
  end
end