class CellPhoneNumberForm < QuestionsForm
  set_attributes_for :intake, :sms_phone_number, :sms_phone_number_confirmation
  before_validation :normalize_phone_numbers

  validates :sms_phone_number, e164_phone: true
  validates :sms_phone_number, confirmation: true
  validates :sms_phone_number_confirmation, presence: true

  def normalize_phone_numbers
    self.sms_phone_number = PhoneParser.normalize(sms_phone_number) if sms_phone_number.present?
    self.sms_phone_number_confirmation = PhoneParser.normalize(sms_phone_number_confirmation) if sms_phone_number_confirmation.present?
  end

  def save
    @intake.update(attributes_for(:intake).except(:sms_phone_number_confirmation))
  end
end
