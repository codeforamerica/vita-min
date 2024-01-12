class GenerateOptionalConsentPdfJob < ApplicationJob
  def perform(consent)
    consent.update_or_create_optional_consent_pdf
    if consent.disclose_consented_at #or maybe we do it here? so do we not want to generate empty form
      consent.update_or_create_f15080_vita_disclosure_pdf
    end
  end

  def priority
    PRIORITY_LOW
  end
end