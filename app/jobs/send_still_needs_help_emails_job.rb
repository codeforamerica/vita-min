class SendStillNeedsHelpEmailsJob < ApplicationJob
  def perform()
    urban_upbound = VitaPartner.find_by_name("Urban Upbound")
    clients = Client.where(vita_partner: urban_upbound).or(Client.where(vita_partner: urban_upbound.child_sites))

    query = 'SELECT distinct client_id from tax_returns WHERE
        status IN (101, 102) AND
        client_id NOT in (SELECT client_id from tax_returns WHERE status NOT IN (101, 102, 406));'
    clients = clients.where(id: ActiveRecord::Base.connection.execute(query).values.flatten)

    client_successes = []
    client_fails = []
    link = "https://getyourrefund.org/portal/still-need-help"
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

      if ClientMessagingService.contact_methods(client).keys.include? :sms_phone_number
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
