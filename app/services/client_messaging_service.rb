class ClientMessagingService
  class << self
    # only sends email if the client can receive emails
    def send_email(client:, user:, body:, attachment: nil, subject: nil, locale: nil, tax_return: nil, to: nil)
      intake = client.intake.nil? ? Archived::Intake2021.where(client_id: client.id).first : client.intake
      return unless intake.email_notification_opt_in_yes?

      if intake.email_notification_opt_in_yes? && !intake.email_address.present?
        DatadogApi.increment('clients.missing_email_for_email_opt_in')
        return
      end

      applied_locale = locale || intake.locale
      replacement_args = { body: body, client: client, preparer: user, tax_return: tax_return, locale: applied_locale }
      replaced_body = ReplacementParametersService.new(**replacement_args).process

      service_type = intake.is_ctc? ? :ctc : :gyr
      service = MultiTenantService.new(service_type)
      subject ||= I18n.t("messages.default_subject_with_service_name", service_name: service.service_name, locale: applied_locale)

      client.outgoing_emails.create!(
        to: to || intake.email_address,
        body: replaced_body,
        subject: subject,
        user: user,
        attachment: attachment,
      )
    end

    def send_email_to_all_signers(client:, user:, body:, attachment: nil, locale: nil, tax_return: nil)
      to = client.email_address
      to += ",#{client.intake.spouse_email_address}" if client.intake.filing_joint_yes?
      args = { to: to, client: client, body: body, user: user, attachment: attachment }
      args[:locale] = locale if locale.present?
      args[:tax_return] = tax_return if tax_return.present?
      send_email(**args)
    end

    def send_system_email(client:, body:, subject:, tax_return: nil, locale: nil, to: nil)
      args = { client: client, body: body, subject: subject, user: nil, to: to }
      args[:tax_return] if tax_return.present?
      args[:locale] if locale.present?
      send_email(**args)
    end

    # only sends text message if client can receive texts
    def send_text_message(client:, user:, body:, tax_return: nil, locale: nil, to: nil)
      intake = client.intake.nil? ? Archived::Intake2021.where(client_id: client.id).first : client.intake
      return unless intake.sms_notification_opt_in_yes?

      if intake.sms_notification_opt_in_yes? && !intake.sms_phone_number.present?
        DatadogApi.increment('clients.missing_sms_phone_number_for_sms_opt_in')
        return
      end

      replacement_args = { body: body, client: client, preparer: user, tax_return: tax_return, locale: locale }
      replaced_body = ReplacementParametersService.new(**replacement_args).process
      client.outgoing_text_messages.create!(
        to_phone_number: to || intake.sms_phone_number,
        sent_at: DateTime.now,
        user: user,
        body: replaced_body,
      )
    end

    def send_system_text_message(client:, body:, tax_return: nil, locale: nil, to: nil)
      args = { client: client, body: body, user: nil, to: to }
      args[:tax_return] = tax_return if tax_return.present?
      args[:locale] = locale if locale.present?
      send_text_message(**args)
    end

    def send_message_to_all_opted_in_contact_methods(client:, user:, body:, subject: nil, locale: nil, tax_return: nil)
      message_records = {
        outgoing_email: nil,
        outgoing_text_message: nil,
      }
      args = { client: client, user: user, body: body }
      args[:tax_return] = tax_return if tax_return.present?
      args[:locale] = locale if locale.present?
      # returns nil unless client opted in to contact method
      message_records[:outgoing_email] = send_email(**args.merge(subject: subject))
      message_records[:outgoing_text_message] = send_text_message(**args)
      message_records
    end

    def send_system_message_to_all_opted_in_contact_methods(client:, message:, tax_return: nil, locale: nil, body_args: {})
      SendAutomatedMessage.new(
        client: client,
        message: message,
        tax_return: tax_return,
        locale: locale,
        body_args: body_args
      ).send_messages
    end

    def contact_methods(client)
      methods = {}
      methods[:email] = client.intake.email_address if client.intake.email_notification_opt_in_yes? && client.intake.email_address.present?
      methods[:sms_phone_number] = client.intake.sms_phone_number if client.intake.sms_notification_opt_in_yes? && client.intake.sms_phone_number.present?
      methods
    end

    def send_bulk_message(tax_return_selection, sender, content_by_locale)
      locale_counts = tax_return_selection.clients.locale_counts
      client_locales = locale_counts.keys.filter { |key| locale_counts[key].nonzero? }

      present_message_bodies_by_locale = content_by_locale.keys.filter { |key| content_by_locale.dig(key, :body).present? }.map(&:to_s)
      raise ArgumentError, "Missing message bodies for some client locales" unless client_locales.all? { |locale| present_message_bodies_by_locale.include?(locale) }

      bulk_client_message = BulkClientMessage.create!(tax_return_selection: tax_return_selection)

      client_locales.each do |locale|
        content = content_by_locale[locale.to_sym]

        # we normalize nil to "en" in locale counts and so we have to check if intake has nil locale for "en"
        locale_on_intake = locale == "en" ? [locale, nil] : locale
        tax_return_selection.clients.accessible_to_user(sender).where(intake: Intake.where(locale: locale_on_intake)).find_each do |client|
          message_records = ClientMessagingService.send_message_to_all_opted_in_contact_methods(
              client: client, user: sender, body: content[:body], subject: content[:subject]
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
