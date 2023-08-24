class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :intake, :sms_notification_opt_in, :email_notification_opt_in
  validate :need_one_communication_method

  def save
    intake.update(attributes_for(:intake))
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new(intake.attributes)
  end

  private

  def need_one_communication_method
    opted_out_of_both = sms_notification_opt_in == "no" && email_notification_opt_in == "no"
    errors.add(:sms_notification_opt_in, I18n.t("forms.errors.need_one_communication_method")) if opted_out_of_both
  end
end
