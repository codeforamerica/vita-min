class PhoneNumberForm < QuestionsForm
  set_attributes_for :intake, :phone_number, :phone_number_confirmation, :phone_number_can_receive_texts
  before_validation :parse_phone_numbers

  validates :phone_number, phone: { message: I18n.t("forms.validators.phone_number_valid") }
  validates :phone_number, confirmation: { message: I18n.t("forms.validators.phone_number_confirmation_match") }
  validates :phone_number_confirmation, presence: true

  def parse_phone_numbers
    if phone_number.present?
      unless phone_number[0] == "1" || phone_number[0..1] == "+1"
        self.phone_number = "1#{phone_number}"
      end
      self.phone_number = Phonelib.parse(phone_number).sanitized
    end

    if phone_number_confirmation.present?
      unless phone_number_confirmation[0] == "1" || phone_number_confirmation[0..1] == "+1"
        self.phone_number_confirmation = "1#{phone_number_confirmation}"
      end
      self.phone_number_confirmation = Phonelib.parse(phone_number_confirmation).sanitized
    end
  end

  def save
    @intake.update(attributes_for(:intake).except(:phone_number_confirmation))
  end
end
