class SurveySender
  def self.send_survey(client, message_class)
    return if client.intake.nil?
   contact_methods = ClientMessagingService.contact_methods(client).keys
    return if contact_methods.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      column_name = message_class::SENT_AT_COLUMN
      return if client.send(column_name).present?

      client.update!(column_name => Time.current)
    end

    locale = client.intake.locale
    message = message_class.new

    if contact_methods.include?(:email)
      ClientMessagingService.send_system_email(
        client: client,
        body: message.email_body(locale: locale, survey_link: message_class.survey_link(client)),
        subject: message.email_subject(locale: locale),
        locale: locale
      )
    end

    if contact_methods.include?(:sms_phone_number)
      ClientMessagingService.send_system_text_message(
        client: client,
        body: message.sms_body(locale: locale, survey_link: message_class.survey_link(client)),
        locale: locale
      )
    end
  end
end
