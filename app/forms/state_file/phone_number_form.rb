module StateFile
  class PhoneNumberForm < QuestionsForm
    set_attributes_for :intake, :phone_number

    before_validation :normalize_phone_number

    validates :phone_number, e164_phone: true

    def normalize_phone_number
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end