class GenerateRequiredConsentPdfJob < ApplicationJob
  def perform(intake)
    intake.update_or_create_required_consent_pdf
  end

  def priority
    PRIORITY_LOW
  end
end