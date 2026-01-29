class DiyNotificationPreferenceForm < Form
  set_attributes_for :diy_intake, :sms_notification_opt_in, :email_notification_opt_in

  def save
    diy_intake.update(attributes_for(:diy_intake))
  end

  def self.existing_attributes(diy_intake)
    HashWithIndifferentAccess.new(diy_intake.attributes)
  end
