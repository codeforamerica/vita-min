class ConsentPdf
  include PdfHelper

  def source_pdf_name
    "consent_form"
  end

  def initialize(intake)
    @intake = intake
    @primary = intake.primary_user
    @spouse = intake.spouse
  end

  def hash_for_pdf
    return {} unless @primary.present?
    data = {
      primary_name: @primary.full_name,
      primary_consented_at: strftime_date(@primary.consented_to_service_at),
      primary_consented_ip: @primary.consented_to_service_ip,
      primary_dob: strftime_date(@primary.parsed_birth_date),
      primary_email: @primary.email,
      primary_phone: @primary.formatted_phone_number,
      primary_ssn_last_four: @primary.ssn_last_four,
    }
    if @spouse.present?
      data.merge!(
        spouse_name: @spouse.full_name,
        spouse_consented_at: strftime_date(@spouse.consented_to_service_at),
        spouse_consented_ip: @spouse.consented_to_service_ip,
        spouse_dob: strftime_date(@spouse.parsed_birth_date),
        spouse_email: @spouse.email,
        spouse_phone: @spouse.formatted_phone_number,
        spouse_ssn_last_four: @spouse.ssn_last_four
      )
    end
    data
  end
end