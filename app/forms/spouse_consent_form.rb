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
    :spouse_first_name,
    :spouse_last_name,
    :spouse_ssn,
    :spouse_tin_type
  )
  set_attributes_for :confirmation, :spouse_ssn_confirmation

  validates_presence_of :spouse_first_name
  validates_presence_of :spouse_last_name

  validates :spouse_tin_type, presence: true
  validates :spouse_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? spouse_tin_type }
  validates :spouse_ssn, individual_taxpayer_identification_number: true, if: -> { spouse_tin_type == "itin" }
  validates_presence_of :spouse_ssn
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
