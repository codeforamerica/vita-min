class ClientMessagingService
  # This module expects the controller to assign @client, typically via load_and_authorize_resource.

  class << self
    def send_email(client, user, body, attachment: nil, subject_locale: nil)
      raise ArgumentError.new("User required") unless user

      OutgoingEmail.create!(
        to: client.email_address,
        body: body,
        subject: I18n.t("messages.default_subject", locale: subject_locale || client.intake.locale),
        sent_at: DateTime.now,
        client: client,
        user: user,
        attachment: attachment
      )
    end

    def send_system_email(client, body, subject)
      OutgoingEmail.create!(
        to: client.email_address,
        body: body,
        subject: subject,
        sent_at: DateTime.now,
        client: client,
        attachment: nil
      )
    end

    def send_text_message(client, user, body)
      raise ActiveRecord::RecordInvalid unless user

      OutgoingTextMessage.create!(
        client: client,
        to_phone_number: client.sms_phone_number,
        sent_at: DateTime.now,
        user: user,
        body: body
      )
    end

    def send_system_text_message(client, body)
      OutgoingTextMessage.create!(
        client: client,
        body: body,
        to_phone_number: client.sms_phone_number,
        sent_at: DateTime.now
      )
    end
  end
end
