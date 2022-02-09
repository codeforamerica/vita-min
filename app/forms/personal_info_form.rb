class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :preferred_name, :phone_number, :phone_number_confirmation, :zip_code, :timezone, :primary_ssn, :primary_tin_type
  set_attributes_for :confirmation, :primary_ssn_confirmation
  before_validation :normalize_phone_numbers

  validates :zip_code, zip_code: true
  validates :preferred_name, presence: true
  validates :phone_number, presence: true, confirmation: true
  validates :phone_number_confirmation, presence: true
  validates_presence_of :primary_tin_type, unless: :itin_applicant?
  validates_presence_of :primary_ssn, unless: :itin_applicant?
  validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
  validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }

  with_options if: -> { (primary_ssn.present? && primary_ssn.remove("-") != intake.primary_ssn) || primary_ssn_confirmation.present? } do
    validates :primary_ssn, confirmation: true
    validates :primary_ssn_confirmation, presence: true
  end

  def normalize_phone_numbers
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    self.phone_number_confirmation = PhoneParser.normalize(phone_number_confirmation) if phone_number_confirmation.present?
  end

  def save
    state = ZipCodes.details(zip_code)[:state]
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation).merge(state_of_residence: state))
  end

  private

  def itin_applicant?
    @intake&.triage&.id_type_need_help?
  end
end
