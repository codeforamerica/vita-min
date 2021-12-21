class ConsentForm < QuestionsForm
  include BirthDateHelper
  set_attributes_for(
    :intake,
    :primary_consented_to_service,
    :primary_consented_to_service_ip,
    :primary_consented_to_service_at,
    :birth_date_year,
    :birth_date_month,
    :birth_date_day,
    :primary_first_name,
    :primary_last_name,
    :primary_ssn,
    :primary_tin_type
  )
  set_attributes_for :confirmation, :primary_ssn_confirmation

  validates_presence_of :primary_first_name
  validates_presence_of :primary_last_name
  validate :valid_birth_date
  validates :primary_tin_type, presence: true
  validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
  validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }
  validates_presence_of :primary_ssn

  with_options if: -> { (primary_ssn.present? && primary_ssn != intake.primary_ssn) || primary_ssn_confirmation.present? } do
    validates :primary_ssn, confirmation: true
    validates :primary_ssn_confirmation, presence: true
  end

  def save
    attributes = attributes_for(:intake)
      .except(:birth_date_year, :birth_date_month, :birth_date_day)
      .merge(
        primary_birth_date: parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day),
        primary_consented_to_service: "yes",
        primary_consented_to_service_at: DateTime.now
      )
    intake.update(attributes)
  end

  def self.existing_attributes(intake)
    attributes = HashWithIndifferentAccess.new(intake.attributes)
    if attributes[:primary_birth_date].present?
      birth_date = attributes[:primary_birth_date]
      attributes.merge!(
        birth_date_year: birth_date.year,
        birth_date_month: birth_date.month,
        birth_date_day: birth_date.day,
      )
    end
    attributes
  end
end
