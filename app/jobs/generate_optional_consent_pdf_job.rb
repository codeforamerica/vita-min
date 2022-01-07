class GenerateOptionalConsentPdfJob < ApplicationJob
  def perform(consent)
    consent.update_or_create_optional_consent_pdf
    if consent.disclose_consented_at
      consent.update_or_create_f15080_vita_disclosure_pdf
    end
  end
end