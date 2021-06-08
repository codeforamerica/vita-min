class SendStillNeedsHelpEmailsJob < ApplicationJob
  def perform()
    urban_upbound = VitaPartner.find_by_name("Urban Upbound")
    clients = Client.where(vita_partner: urban_upbound).or(Client.where(vita_partner: urban_upbound.child_sites))

    clients = clients.joins(:tax_returns).where(tax_returns: { status: ["intake_ready", "intake_in_progress"] }).select do |client|
      client.tax_returns.all? { |tax_return| ["intake_ready", "intake_in_progress", "file_not_filing"].include? tax_return.status }
    end.uniq

    client_successes = []
    client_fails = []
    link = "https://getyourrefund.org/portal/still-needs-help"
    clients.each do |client|
      if StillNeedsHelpService.trigger_still_needs_help_flow(client)
        client_successes << client.id
      else
        client_fails << client.id
      end

      puts "Sending messages to Client with id #{client.id}"
      locale = client.intake.locale
      if ClientMessagingService.contact_methods(client).keys.include? :email
        ClientMessagingService.send_system_email(
          client: client,
          body: I18n.t("messages.still_needs_help.email.body", locale: locale, link: link),
          subject: I18n.t("messages.still_needs_help.email.subject", locale: locale),
          locale: locale
        )
      end

      preferred_contact_method = ClientMessagingService.contact_methods(client).keys.first
      if preferred_contact_method == :sms_phone_number
        ClientMessagingService.send_system_text_message(
          client: client,
          body: I18n.t("messages.still_needs_help.sms.body", locale: locale, link: link),
          locale: locale
        )
      end
    end

    puts "Successfully updated clients: #{client_successes}"
    puts "Failed to update clients: #{client_fails}"
  end
end
