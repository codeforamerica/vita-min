class OptionalConsentPdfJob < ApplicationJob
  def perform(consent)
    consent.update_or_create_optional_consent_pdf
  end
end