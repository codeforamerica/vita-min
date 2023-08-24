class OptionalConsentPdf
  include PdfHelper

  def source_pdf_name
    "2021-GYR-Optional-Consent"
  end

  def initialize(consent)
    @consent = consent
  end

  def hash_for_pdf
    {
      use: @consent.use_consented_at ? "Yes" : "No",
      disclose: @consent.disclose_consented_at? ? "Yes" : "No",
      relational_efin: @consent.relational_efin_consented_at? ? "Yes" : "No",
      global_carryforward: @consent.global_carryforward_consented_at? ? "Yes" : "No",
    }
  end

  def document_type
    DocumentTypes::OptionalConsentForm
  end

  def output_filename
    "optional-consent-2021.pdf"
  end
end
