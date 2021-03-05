class SendClientCompletionSurveyJob < ApplicationJob
  def perform(client)
    ClientMessagingService.send_system_email(
      client,
      I18n.t("messages.surveys.completion.email.body", locale: client.intake.locale, client_id: client.id),
      I18n.t("messages.surveys.completion.email.subject", locale: client.intake.locale)
    )
  end
end
