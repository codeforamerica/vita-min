class ClientMessagingService
  class << self
    def send_email(client:, user:, body:, attachment: nil, subject: nil, locale: nil, tax_return: nil, to: nil)
      applied_locale = locale || client.intake.locale
      replacement_args = { body: body, client: client, preparer: user, tax_return: tax_return, locale: applied_locale }
      replaced_body = ReplacementParametersService.new(**replacement_args).process
      OutgoingEmail.create!(
        to: to || client.email_address,
        body: replaced_body,
        subject: subject || I18n.t("messages.default_subject", locale: applied_locale),
        client: client,
        user: user,
        attachment: attachment,
      )
    end

    def send_email_to_all_signers(client:, user:, body:, attachment: nil, locale: nil, tax_return: nil)
      to = client.email_address
      to += ",#{client.intake.spouse_email_address}" if client.intake.filing_joint == "yes"
      args = { to: to, client: client, body: body, user: user, attachment: attachment }
      args[:locale] = locale if locale.present?
      args[:tax_return] = tax_return if tax_return.present?
      send_email(**args)
    end

    def send_system_email(client:, body:, subject:, tax_return: nil, locale: nil)
      args = { client: client, body: body, subject: subject, user: nil }
      args[:tax_return] if tax_return.present?
      args[:locale] if locale.present?
      send_email(**args)
    end

    def send_text_message(client:, user:, body:, tax_return: nil, locale: nil)
      replacement_args = { body: body, client: client, preparer: user, tax_return: tax_return, locale: locale }
      replaced_body = ReplacementParametersService.new(**replacement_args).process
      OutgoingTextMessage.create!(
        client: client,
        to_phone_number: client.sms_phone_number,
        sent_at: DateTime.now,
        user: user,
        body: replaced_body,
      )
    end

    def send_system_text_message(client:, body:, tax_return: nil, locale: nil)
      args = { client: client, body: body, user: nil }
      args[:tax_return] = tax_return if tax_return.present?
      args[:locale] = locale if locale.present?
      send_text_message(**args)
    end

    def send_message_to_all_opted_in_contact_methods(client:, user:, body:, locale: nil, tax_return: nil)
      message_records = {
        outgoing_email: nil,
        outgoing_text_message: nil,
      }
      args = { client: client, user: user, body: body }
      args[:tax_return] = tax_return if tax_return.present?
      args[:locale] = locale if locale.present?
      if client.intake.email_notification_opt_in_yes? && client.email_address.present?
        message_records[:outgoing_email] = send_email(**args)
      end
      if client.intake.sms_notification_opt_in_yes? && client.sms_phone_number.present?
        message_records[:outgoing_text_message] = send_text_message(**args)
      end
      message_records
    end

    def send_system_message_to_all_opted_in_contact_methods(client:, message:, tax_return: nil, locale: )
      message_records = {
        outgoing_email: nil,
        outgoing_text_message: nil,
      }
      args = {
        client: client,
        body: message.email_body(locale: locale),
        subject: message.email_subject(locale: locale),
        locale: locale
      }
      args[:tax_return] = tax_return if tax_return.present?

      if client.intake.email_notification_opt_in_yes? && client.email_address.present? && message.email_body.present?
        message_records[:outgoing_email] = send_system_email(**args)
      end
      if client.intake.sms_notification_opt_in_yes? && client.sms_phone_number.present? && message.sms_body.present?
        args.delete(:subject)
        args[:body] = message.sms_body(locale: locale)
        message_records[:outgoing_text_message] = send_system_text_message(**args)
      end
      message_records
    end

    def contact_methods(client)
      methods = {}
      methods[:email] = client.intake.email_address if client.intake.email_notification_opt_in_yes? && client.intake.email_address.present?
      methods[:sms_phone_number] = client.intake.sms_phone_number if client.intake.sms_notification_opt_in_yes? && client.intake.sms_phone_number.present?
      methods
    end

    def send_bulk_message(tax_return_selection, sender, **message_bodies_by_locale)
      locale_counts = tax_return_selection.clients.locale_counts
      client_locales = locale_counts.keys.filter { |key| locale_counts[key].nonzero? }

      present_message_bodies_by_locale = message_bodies_by_locale.keys.filter { |key| message_bodies_by_locale[key].present? }.map(&:to_s)
      raise ArgumentError, "Missing message bodies for some client locales" unless client_locales.all? { |locale| present_message_bodies_by_locale.include?(locale) }

      bulk_client_message = BulkClientMessage.create!(tax_return_selection: tax_return_selection)

      client_locales.each do |locale|
        message_body = message_bodies_by_locale[locale.to_sym]

        # we normalize nil to "en" in locale counts and so we have to check if intake has nil locale for "en"
        locale_on_intake = locale == "en" ? [locale, nil] : locale
        tax_return_selection.clients.accessible_to_user(sender).where(intake: Intake.where(locale: locale_on_intake)).find_each do |client|
          message_records = ClientMessagingService.send_message_to_all_opted_in_contact_methods(
              client: client, user: sender, body: message_body
          )

          if message_records[:outgoing_text_message].present?
            bulk_client_message.outgoing_text_messages << message_records[:outgoing_text_message]
          end

          if message_records[:outgoing_email].present?
            bulk_client_message.outgoing_emails << message_records[:outgoing_email]
          end
        end
      end
      bulk_client_message
    end

  end
end
