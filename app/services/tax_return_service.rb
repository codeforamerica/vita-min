class TaxReturnService
  def self.handle_status_change(form)
    action_list = []

    form.tax_return.status_last_changed_by = form.current_user
    form.tax_return.update(status: form.status)
    action_list << I18n.t("hub.clients.update_take_action.flash_message.status")
    SystemNote::StatusChange.generate!(initiated_by: form.current_user, tax_return: form.tax_return)
    if form.message_body.present?
      args = { client: form.client, user: form.current_user, body: form.message_body, tax_return: form.tax_return, locale: form.locale }
      case form.contact_method
      when "email"
        if form.status == "review_signature_requested"
          ClientMessagingService.send_email_to_all_signers(**args)
        else
          ClientMessagingService.send_email(**args)
        end
        action_list << I18n.t("hub.clients.update_take_action.flash_message.email")
      when "text_message"
        ClientMessagingService.send_text_message(**args)
        action_list << I18n.t("hub.clients.update_take_action.flash_message.text_message")
      end
    end

    if form.internal_note_body.present?
      Note.create!(
        body: form.internal_note_body,
        client: form.client,
        user: form.current_user
      )
      action_list << I18n.t("hub.clients.update_take_action.flash_message.internal_note")
    end

    action_list
  end
end