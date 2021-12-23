class F15080VitaConsentToDisclosePdf
  include PdfHelper

  def source_pdf_name
    "f15080-TY2021"
  end

  def output_filename
    "F15080 - VITA Consent To Disclose"
  end

  def document_type
    DocumentTypes::Form15080
  end

  def initialize(intake)
    @intake = intake
  end

  def hash_for_pdf
    return {} unless @intake.primary_consented_to_service_at.present?

    data = {
        primary_legal_name: @intake.primary_full_name,
        primary_consented_at: strftime_date(@intake.primary_consented_to_service_at),
    }
    if @intake.spouse_consented_to_service_at.present?
      data.merge!(
        spouse_legal_name: @intake.spouse_full_name,
        spouse_consented_at: strftime_date(@intake.spouse_consented_to_service_at),
      )
    end
    data
  end
end