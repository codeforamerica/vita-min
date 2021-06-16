class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    best_contact_method = ClientMessagingService.contact_methods(client).keys.first
    return if best_contact_method.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      return if client.completion_survey_sent_at.present?

      client.update!(completion_survey_sent_at: Time.current)
    end

    is_drop_off_client = client.tax_returns.pluck(:service_type).any? "drop_off"
    survey_code = is_drop_off_client ? "SV_ebtml6MMfhf8Vsa" : "SV_exiL2bLJx8GvjGC"
    survey_link = "https://codeforamerica.co1.qualtrics.com/jfe/form/#{survey_code}?ExternalDataReference=#{client.id}"

    locale = client.intake.locale
    message = AutomatedMessage::CompletionSurvey.new

    case best_contact_method
    when :email
      ClientMessagingService.send_system_email(
        client: client,
        body: message.email_body(locale: locale, survey_link: survey_link),
        subject: message.email_subject(locale: locale),
        locale: locale
      )
    when :sms_phone_number
      ClientMessagingService.send_system_text_message(
        client: client,
        body: message.sms_body(locale: locale, survey_link: survey_link),
        locale: locale
      )
    end
  end
end
