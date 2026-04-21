class DiyNotificationPreferenceForm < DiyForm
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :sms_notification_opt_in, :email_notification_opt_in
end
