class ClientMessagingService
  class << self
    def send_email(client, user, body, attachment: nil, subject_locale: nil)
      create_outgoing_email(attachment, body, client, client.email_address, subject_locale, user)
    end

    def send_email_to_all_signers(client, user, body, attachment: nil, subject_locale: nil)
      to = client.email_address
      to += ",#{client.intake.spouse_email_address}" if client.intake.filing_joint_yes?

      create_outgoing_email(attachment, body, client, to, subject_locale, user)
    end

    def send_system_email(client, body, subject)
      OutgoingEmail.create!(
        to: client.email_address,
        body: body,
        subject: subject,
        sent_at: DateTime.now,
        client: client,
        attachment: nil
      )
    end

    def send_text_message(client, user, body)
      raise ActiveRecord::RecordInvalid unless user

      OutgoingTextMessage.create!(
        client: client,
        to_phone_number: client.sms_phone_number,
        sent_at: DateTime.now,
        user: user,
        body: body
      )
    end

    def send_system_text_message(client, body)
      OutgoingTextMessage.create!(
        client: client,
        body: body,
        to_phone_number: client.sms_phone_number,
        sent_at: DateTime.now
      )
    end

    def send_message_to_all_opted_in_contact_methods(client, user, body)
      message_records = {
        outgoing_email: nil,
        outgoing_text_message: nil,
      }
      if client.intake.email_notification_opt_in_yes? && client.email_address.present?
        message_records[:outgoing_email] = send_email(client, user, body)
      end
      if client.intake.sms_notification_opt_in_yes? && client.sms_phone_number.present?
        message_records[:outgoing_text_message] = send_text_message(client, user, body)
      end
      message_records
    end

    def send_system_message_to_all_opted_in_contact_methods(client, email_body: nil, sms_body: nil, subject: nil)
      message_records = {
        outgoing_email: nil,
        outgoing_text_message: nil,
      }
      if client.intake.email_notification_opt_in_yes? && client.email_address.present? && email_body.present?
        message_records[:outgoing_email] = send_system_email(client, email_body, subject)
      end
      if client.intake.sms_notification_opt_in_yes? && client.sms_phone_number.present? && sms_body.present?
        message_records[:outgoing_text_message] = send_system_text_message(client, sms_body)
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
      client_locales = locale_counts.keys.filter { |key| locale_counts[key].nonzero? }.sort

      present_message_bodies_by_locale = message_bodies_by_locale.keys.filter { |key| message_bodies_by_locale[key].present? }.map(&:to_s).sort
      raise ArgumentError, "Missing message bodies for some client locales" unless client_locales == present_message_bodies_by_locale

      bulk_client_message = BulkClientMessage.create!(tax_return_selection: tax_return_selection)

      client_locales.each do |locale|
        message_body = message_bodies_by_locale[locale.to_sym]

        # we normalize nil to "en" in locale counts and so we have to check if intake has nil locale for "en"
        locale_on_intake = locale == "en" ? [locale, nil] : locale
        tax_return_selection.clients.accessible_to_user(sender).where(intake: Intake.where(locale: locale_on_intake)).find_each do |client|
          message_records = ClientMessagingService.send_message_to_all_opted_in_contact_methods(
            client, sender, message_body
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

    private

    def create_outgoing_email(attachment, body, client, to, subject_locale, user)
      raise ArgumentError.new("User required") unless user

      OutgoingEmail.create!(
        to: to,
        body: body,
        subject: I18n.t("messages.default_subject", locale: subject_locale || client.intake.locale),
        sent_at: DateTime.now,
        client: client,
        user: user,
        attachment: attachment
      )
    end
  end
end
