class TaxReturnService
  def self.handle_status_change(form)
    send_email(form.message_body, form.current_user, form.client, subject_locale: locale)
  end

  private
  def send_email(body, user, client, attachment: nil, subject_locale: nil)
    raise ActiveRecord::RecordInvalid unless user

    OutgoingEmail.create!(
      to: client.email_address,
      body: body,
      subject: I18n.t("messages.default_subject", locale: subject_locale || @client.intake.locale),
      sent_at: DateTime.now,
      client: client,
      user: user,
      attachment: attachment
    )
  end
end