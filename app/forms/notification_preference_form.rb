class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :intake, :sms_phone_number, :sms_notification_opt_in, :email_notification_opt_in
  before_validation :parse_sms_phone_number
  validate :need_phone_number_for_sms_opt_in
  validate :need_one_communication_method
  validates :sms_phone_number, allow_blank: true, e164_phone: true

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
    self.sms_phone_number = PhoneParser.normalize(sms_phone_number) if sms_phone_number.present?
  end

  def need_phone_number_for_sms_opt_in
    has_phone_if_needed = sms_notification_opt_in == "yes" ? sms_phone_number.present? : true
    errors.add(:sms_phone_number, I18n.t("forms.errors.need_phone_number")) unless has_phone_if_needed
  end

  def need_one_communication_method
    opted_out_of_both = sms_notification_opt_in == "no" && email_notification_opt_in =="no"
    errors.add(:sms_notification_opt_in, I18n.t("forms.errors.need_one_communication_method")) if opted_out_of_both
  end
end
