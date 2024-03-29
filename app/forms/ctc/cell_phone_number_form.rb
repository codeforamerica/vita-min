module Ctc
  class CellPhoneNumberForm < QuestionsForm
    set_attributes_for :intake, :sms_phone_number
    set_attributes_for :confirmation, :sms_phone_number_confirmation
    before_validation :normalize_phone_numbers

    validates :sms_phone_number, confirmation: true
    validates :sms_phone_number_confirmation, presence: true
    validates :sms_phone_number, e164_phone: true

    def save
      attributes = attributes_for(:intake).merge({ sms_notification_opt_in: "yes" })
      attributes[:sms_phone_number_verified_at] = nil if @intake.sms_phone_number != sms_phone_number
      @intake.update(attributes)
    end

    private

    def normalize_phone_numbers
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number) if sms_phone_number.present?
      self.sms_phone_number_confirmation = PhoneParser.normalize(sms_phone_number_confirmation) if sms_phone_number_confirmation.present?
    end
  end
end
