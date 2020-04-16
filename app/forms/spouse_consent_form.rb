class SpouseConsentForm < QuestionsForm
  include BirthDateHelper

  set_attributes_for(
    :intake,
    :spouse_consented_to_service,
    :spouse_consented_to_service_ip,
    :spouse_consented_to_service_at,
    :birth_date_year,
    :birth_date_month,
    :birth_date_day,
    :spouse_full_legal_name,
    :spouse_last_four_ssn
  )

  validates_presence_of :spouse_full_legal_name, message: "Please enter your name."
  validates_length_of :spouse_last_four_ssn, maximum: 4, minimum: 4, message: "Please enter the last four digits of your SSN or ITIN."
  validate :valid_birth_date

  def save
    attributes = attributes_for(:intake)
      .except(:birth_date_year, :birth_date_month, :birth_date_day)
      .merge(
        spouse_birth_date: parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day),
        spouse_consented_to_service: "yes",
        spouse_consented_to_service_at: DateTime.now
      )
    intake.update(attributes)
  end

  def self.existing_attributes(intake)
    attributes = HashWithIndifferentAccess.new(intake.attributes)
    if attributes[:spouse_birth_date].present?
      birth_date = attributes[:spouse_birth_date]
      attributes.merge!(
        birth_date_year: birth_date.year,
        birth_date_month: birth_date.month,
        birth_date_day: birth_date.day,
        )
    end
    attributes
  end
end
