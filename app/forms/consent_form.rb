class ConsentForm < QuestionsForm
  include BirthDateHelper
  set_attributes_for(
    :intake,
    :birth_date_year,
    :birth_date_month,
    :birth_date_day,
    :primary_first_name,
    :primary_last_name,
  )

  validates_presence_of :primary_first_name
  validates_presence_of :primary_last_name
  validate :valid_birth_date

  def save
    attributes = attributes_for(:intake)
      .except(:birth_date_year, :birth_date_month, :birth_date_day)
      .merge(
        primary_birth_date: parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day),
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
