class SendClientInProgressSurveyJob < ApplicationJob
  def perform(client)
    best_contact_method = ClientMessagingService.contact_methods(client).keys.first
    return if best_contact_method.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      return if client.in_progress_survey_sent_at.present?

      client.update!(in_progress_survey_sent_at: Time.current)
    end

    survey_link = "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_6PDoi6ecHeQYiuq?ExternalDataReference=#{client.id}"
    case best_contact_method
    when :email
      ClientMessagingService.send_system_email(
        client,
        I18n.t("messages.surveys.in_progress.email.body", locale: client.intake.locale, survey_link: survey_link, preferred_name: client.preferred_name, doc_upload_link: client.intake.requested_docs_token_link),
        I18n.t("messages.surveys.in_progress.email.subject", locale: client.intake.locale)
      )
    when :sms_phone_number
      ClientMessagingService.send_system_text_message(
        client,
        I18n.t("messages.surveys.in_progress.text", locale: client.intake.locale, survey_link: survey_link, preferred_name: client.preferred_name),
      )
    end
  end
end
