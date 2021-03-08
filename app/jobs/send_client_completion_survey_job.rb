class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    return if client.completion_survey_sent_at.present?

    ClientMessagingService.send_system_email(
      client,
      I18n.t("messages.surveys.completion.email.body", locale: client.intake.locale, client_id: client.id),
      I18n.t("messages.surveys.completion.email.subject", locale: client.intake.locale)
    )
    client.update!(completion_survey_sent_at: Time.current)
  end
end
