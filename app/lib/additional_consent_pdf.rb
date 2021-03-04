class AdditionalConsentPdf
  include PdfHelper

  def source_pdf_name
    "2021-GYR-Additional-Consent"
  end

  def initialize(client)
    @client = client
  end

  def hash_for_pdf
    return {} unless @client.intake.primary_consented_to_service_at.present?
    {
        use: @client.consent.use_consented_at ? "Yes" : "No",
        disclose: @client.consent.disclose_consented_at? ? "Yes" : "No",
        relational_efin: @client.consent.relational_efin_consented_at? ? "Yes" : "No",
        global_carryforward: @client.consent.global_carryforward_consented_at? ? "Yes" : "No",
    }
  end
end
