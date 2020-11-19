module MessageSending
  def send_email(body, attachment: nil, subject_locale: nil)
    outgoing_email = OutgoingEmail.create!(
      to: @client.email_address,
      body: body,
      subject: I18n.t("email.user_message.subject", locale: subject_locale || @client.intake.locale),
      sent_at: DateTime.now,
      client: @client,
      user: current_user,
      attachment: attachment
    )
    OutgoingEmailMailer.user_message(outgoing_email: outgoing_email).deliver_later
    ClientChannel.broadcast_contact_record(outgoing_email)
  end

  def send_text_message(client, body:)
    outgoing_text_message = OutgoingTextMessage.create!(
      client: client,
      to_phone_number: client.sms_phone_number,
      sent_at: DateTime.now,
      user: current_user,
      body: body
    )
    SendOutgoingTextMessageJob.perform_later(outgoing_text_message.id)
    ClientChannel.broadcast_contact_record(outgoing_text_message)
  end
end