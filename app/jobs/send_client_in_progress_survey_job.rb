class SendClientInProgressSurveyJob < ApplicationJob
  delegate :new_portal_client_login_url, to: "Rails.application.routes.url_helpers"
  def perform(client)
    best_contact_method = ClientMessagingService.contact_methods(client).keys.first
    return if best_contact_method.blank?

    # Avoid sending duplicate emails; use lock since there are multiple job workers
    client.with_lock do
      return if client.in_progress_survey_sent_at.present?

      client.update!(in_progress_survey_sent_at: Time.current)
    end

    survey_link = "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_6PDoi6ecHeQYiuq?ExternalDataReference=#{client.id}"
    locale = client.intake.locale
    message = AutomatedMessage::InProgressSurvey.new

    case best_contact_method
    when :email
      ClientMessagingService.send_system_email(
        client: client,
        body: message.email_body(locale: locale, survey_link: survey_link),
        subject: message.email_subject(locale: client.intake.locale),
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
