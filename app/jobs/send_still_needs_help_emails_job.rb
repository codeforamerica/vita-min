class SendStillNeedsHelpEmailsJob < ApplicationJob
  def perform()
    urban_upbound = VitaPartner.find_by_name("Urban Upbound")
    clients = Client.where(vita_partner_id: urban_upbound.id).or(Client.where(vita_partner: VitaPartner.where(parent_organization_id: urban_upbound.id)))

    clients = clients.joins(:tax_returns).where(tax_returns: { status: ["intake_ready", "intake_in_progress"] }).select do |client|
      client.tax_returns.all? { |tax_return| ["intake_ready", "intake_in_progress", "file_not_filing"].include? tax_return.status }
    end.uniq

    tax_returns = clients.map(&:tax_returns).flatten
    tr_successes = []
    tr_fails = []
    tax_returns.each do |tax_return|
      if tax_return.update(status: "file_not_filing")
        tr_successes << tax_return.id
      else
        tr_fails << tax_return.id
      end
    end
    puts "Successfully updated tax returns: #{tr_successes}"
    puts "Failed to update tax returns: #{tr_fails}"

    client_successes = []
    client_fails = []
    link = "https://getyourrefund.org/portal/still-needs-help"
    clients.each do |client|
      if client.update(triggered_still_needs_help_at: Time.now)
        client_successes << client.id
      else
        client_fails << client.id
      end

      puts "Sending messages to Client with id #{client.id}"
      locale = client.intake.locale
      ClientMessagingService.send_system_email(
        client: client,
        body: I18n.t("messages.still_needs_help.email.body", locale: locale, link: link),
        subject: I18n.t("messages.still_needs_help.email.subject", locale: locale),
        locale: locale
      )

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
