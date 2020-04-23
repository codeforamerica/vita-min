class ConsentPdf
  include PdfHelper

  def source_pdf_name
    "consent_form"
  end

  def initialize(intake)
    @intake = intake
  end

  def hash_for_pdf
    return {} unless @intake.primary_consented_to_service_at.present?
    data = {
      primary_name: @intake.primary_full_name,
      primary_consented_at: strftime_date(@intake.primary_consented_to_service_at),
      primary_consented_ip: @intake.primary_consented_to_service_ip,
      primary_dob: strftime_date(@intake.primary_birth_date),
      primary_email: @intake.email_address,
      primary_phone: @intake.formatted_phone_number,
      primary_ssn_last_four: @intake.primary_last_four_ssn,
    }
    if @intake.spouse_consented_to_service_at.present?
      data.merge!(
        spouse_name: @intake.spouse_full_name,
        spouse_consented_at: strftime_date(@intake.spouse_consented_to_service_at),
        spouse_consented_ip: @intake.spouse_consented_to_service_ip,
        spouse_dob: strftime_date(@intake.spouse_birth_date),
        spouse_ssn_last_four: @intake.spouse_last_four_ssn
      )
    end
    data
  end
end