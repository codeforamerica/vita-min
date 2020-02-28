class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :user, :sms_notification_opt_in, :email_notification_opt_in
  validate :validate_one_method_selected

  def save
    intake.primary_user.update(attributes_for(:user))
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new(intake.primary_user.attributes)
  end

  private

  def validate_one_method_selected
    unless sms_notification_opt_in == "yes" || email_notification_opt_in == "yes"
      errors.add(:base, "We need a way to get in touch in order to help you.")
    end
  end
end
