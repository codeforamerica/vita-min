class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    best_contact_method = ClientMessagingService.contact_methods(client).keys.first
    return if best_contact_method.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      return if client.completion_survey_sent_at.present?

      client.update!(completion_survey_sent_at: Time.current)
    end

    survey_link = "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_exiL2bLJx8GvjGC?ExternalDataReference=#{client.id}"
    case best_contact_method
    when :email
      ClientMessagingService.send_system_email(
        client,
        I18n.t("messages.surveys.completion.email.body", locale: client.intake.locale, survey_link: survey_link),
        I18n.t("messages.surveys.completion.email.subject", locale: client.intake.locale)
      )
    when :sms_phone_number
      ClientMessagingService.send_system_text_message(
        client,
        I18n.t("messages.surveys.completion.text", locale: client.intake.locale, survey_link: survey_link),
      )
    end
  end
end
