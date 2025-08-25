class SendUserNotificationEmailJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def perform(user_notification_email_id)
    notification_email = UserNotificationEmail.find(user_notification_email_id)
    # mailer_response = StateFile::NotificationMailer.user_message(notification_email: notification_email).deliver_now
    notification_email.update(message_id: mailer_response.message_id, sent_at: DateTime.now)
  end

  def priority
    PRIORITY_LOW
  end
end