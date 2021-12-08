class PersonalInfoForm < QuestionsForm
  set_attributes_for :intake, :preferred_name, :phone_number, :phone_number_confirmation, :zip_code, :timezone
  before_validation :normalize_phone_numbers

  validates :zip_code, zip_code: true
  validates :preferred_name, presence: true
  validates :phone_number, presence: true, confirmation: true
  validates :phone_number_confirmation, presence: true

  def normalize_phone_numbers
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    self.phone_number_confirmation = PhoneParser.normalize(phone_number_confirmation) if phone_number_confirmation.present?
  end

  def save
    state = ZipCodes.details(zip_code)[:state]
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation).merge(state_of_residence: state))
  end
end
