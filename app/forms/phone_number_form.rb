class PhoneNumberForm < QuestionsForm
  set_attributes_for :intake, :phone_number, :phone_number_confirmation, :phone_number_can_receive_texts
  before_validation :normalize_phone_numbers

  validates :phone_number, e164_phone: true
  validates :phone_number, confirmation: true
  validates :phone_number_confirmation, presence: true

  def normalize_phone_numbers
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    self.phone_number_confirmation = PhoneParser.normalize(phone_number_confirmation) if phone_number_confirmation.present?
  end

  def save
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation))
  end
end
