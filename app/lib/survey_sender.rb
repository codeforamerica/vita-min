class SurveySender
  def self.send_survey(client, message_class)
    return if client.intake.nil?
    best_contact_method = ClientMessagingService.contact_methods(client).keys.first
    return if best_contact_method.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      column_name = message_class::SENT_AT_COLUMN
      return if client.send(column_name).present?

      client.update!(column_name => Time.current)
    end

    locale = client.intake.locale
    message = message_class.new

    case best_contact_method
    when :email
      ClientMessagingService.send_system_email(
        client: client,
        body: message.email_body(locale: locale, survey_link: message_class.survey_link(client)),
        subject: message.email_subject(locale: locale),
        locale: locale
      )
    when :sms_phone_number
      ClientMessagingService.send_system_text_message(
        client: client,
        body: message.sms_body(locale: locale, survey_link: message_class.survey_link(client)),
        locale: locale
      )
    end
  end
end
