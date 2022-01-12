class SendClientSaveCtcLetterMessageJob < ApplicationJob
  def perform(client)
    return if client.intake.email_notification_opt_in != "yes" && client.intake.sms_notification_opt_in != "yes"

    service_name = client.intake.is_ctc? ? "GetCTC" : "GetYourRefund"

    ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
      client: client,
      message: AutomatedMessage::SaveCtcLetter,
      tax_return: nil,
      locale: client.locale,
      body_args: { service_name: service_name }
    )
  end
end