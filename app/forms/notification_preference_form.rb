class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :user, :sms_notification_opt_in, :email_notification_opt_in

  def save
    intake.primary_user.update(attributes_for(:user))
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new(intake.primary_user.attributes)
  end
end
