module MessageSending
  # This module expects the controller to assign @client, typically via load_and_authorize_resource.

  def send_email(body, attachment: nil, subject_locale: nil)
    outgoing_email = OutgoingEmail.create!(
      to: @client.email_address,
      body: body,
      subject: I18n.t("messages.default_subject", locale: subject_locale || @client.intake.locale),
      sent_at: DateTime.now,
      client: @client,
      user: current_user,
      attachment: attachment
    )
    OutgoingEmailMailer.user_message(outgoing_email: outgoing_email).deliver_later
    ClientChannel.broadcast_contact_record(outgoing_email)
  end

  def send_system_email(body, subject)
    outgoing_email = SystemEmail.create!(
      to: @client.email_address,
      body: body,
      subject: subject,
      sent_at: DateTime.now,
      client: @client,
      attachment: nil
    )
    OutgoingEmailMailer.user_message(outgoing_email: outgoing_email).deliver_later
    ClientChannel.broadcast_contact_record(outgoing_email)
  end

  def send_text_message(body)
    outgoing_text_message = OutgoingTextMessage.create!(
      client: @client,
      to_phone_number: @client.sms_phone_number,
      sent_at: DateTime.now,
      user: current_user,
      body: body
    )
    SendOutgoingTextMessageJob.perform_later(outgoing_text_message)
    ClientChannel.broadcast_contact_record(outgoing_text_message)
  end

  def send_system_text_message(body)
    system_text_message = SystemTextMessage.create!(
      client: @client,
      body: body,
      to_phone_number: @client.sms_phone_number,
      sent_at: DateTime.now
    )
    SendOutgoingTextMessageJob.perform_later(system_text_message)
    ClientChannel.broadcast_contact_record(system_text_message)
  end
end
