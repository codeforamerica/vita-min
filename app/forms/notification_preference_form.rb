class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :intake, :sms_phone_number, :sms_notification_opt_in, :email_notification_opt_in
  before_validation :parse_sms_phone_number
  validate :need_phone_number_for_sms_opt_in

  def save
    intake.update(attributes_for(:intake))
  end

  def self.existing_attributes(intake)
    if intake.phone_number_can_receive_texts_yes? && intake.phone_number.present?
      intake.assign_attributes(sms_phone_number: intake.phone_number)
    end
    HashWithIndifferentAccess.new(intake.attributes)
  end

  private

  def parse_sms_phone_number
    if sms_phone_number.present?
      unless sms_phone_number[0] == "1" || sms_phone_number[0..1] == "+1"
        self.sms_phone_number = "1#{sms_phone_number}"
      end
      self.sms_phone_number = Phonelib.parse(sms_phone_number).sanitized
    end
  end

  def need_phone_number_for_sms_opt_in
    has_phone_if_needed = sms_notification_opt_in == "yes" ? sms_phone_number.present? : true
    errors.add(:sms_phone_number, "Please enter a cell phone number.") unless has_phone_if_needed
  end
end
