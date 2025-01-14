module StateFile
  class SendNotificationTextMessageJob < ApplicationJob
    def perform(state_file_notification_text_message_id)
      state_file_notification_text_message = StateFileNotificationTextMessage.find(state_file_notification_text_message_id)
      twilio = TwilioService.new(:statefile)

      message = twilio.send_text_message(
        to: state_file_notification_text_message.to_phone_number,
        body: state_file_notification_text_message.body,
        outgoing_text_message: state_file_notification_text_message
      )
      if message
        state_file_notification_text_message.update(
          twilio_sid: message.sid,
          twilio_status: message.status,
          error_code: message.error_code,
          sent_at: DateTime.now
        )
      end
    end

    def priority
      PRIORITY_HIGH
    end
  end
end