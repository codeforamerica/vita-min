class NotificationPreferenceForm < QuestionsForm
  set_attributes_for :user, :sms_notification_opt_in, :email_notification_opt_in

  def save
    # TODO: Replace with the intake.primary_user method when it's merged:
    primary_user = intake.users.where.not(is_spouse: true).first
    primary_user.update(attributes_for(:user))
  end

  def self.existing_attributes(intake)
    # TODO: Replace with the intake.primary_user method when it's merged:
    primary_user = intake.users.where.not(is_spouse: true).first
    HashWithIndifferentAccess.new(primary_user.attributes)
  end
end
