module StateFile
  class SendNotificationEmailJob < ApplicationJob
    retry_on Mailgun::CommunicationError

    def perform(state_file_notification_email_id)
      notification_email = StateFileNotificationEmail.find(state_file_notification_email_id)
      mailer_response = StateFile::NotificationMailer.user_message(notification_email: notification_email).deliver_now
      notification_email.update(message_id: mailer_response.message_id, sent_at: DateTime.now)
    end

    def priority
      PRIORITY_HIGH
    end
  end
end