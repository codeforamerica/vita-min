class TaxReturnService
  def self.handle_status_change(form)
    action_list = []

    form.tax_return.update(status: form.status)
    action_list << I18n.t("hub.clients.update_take_action.flash_message.status")
    SystemNote.create_status_change_note(form.current_user, form.tax_return)

    if form.message_body.present?
      case form.contact_method
      when "email"
        if form.status == "review_signature_requested"
          ClientMessagingService.send_email_to_all_signers(form.client, form.current_user, form.message_body, subject_locale: form.locale)
        else
          ClientMessagingService.send_email(form.client, form.current_user, form.message_body, subject_locale: form.locale)
        end
        action_list << I18n.t("hub.clients.update_take_action.flash_message.email")
      when "text_message"
        ClientMessagingService.send_text_message(form.client, form.current_user, form.message_body)
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