class GenerateRequiredConsentPdfJob < ApplicationJob
  def perform(intake)
    intake.update_or_create_required_consent_pdf
  end
end