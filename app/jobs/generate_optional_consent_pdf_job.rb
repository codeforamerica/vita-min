class GenerateOptionalConsentPdfJob < ApplicationJob
  def perform(consent)
    consent.update_or_create_optional_consent_pdf
  end

  def priority
    PRIORITY_LOW
  end
end