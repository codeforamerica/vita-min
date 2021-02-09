class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email
    attachment = outgoing_email.attachment

    @body = ReplacementParametersService.new(
      body: outgoing_email.body,
      client: outgoing_email.client,
      locale: outgoing_email.client.intake.locale
    ).process_sensitive_data

    if attachment.present?
      attachments[attachment.filename.to_s] = attachment.blob.download
    end

    DatadogApi.increment("mailgun.outgoing_emails.sent")

    mail(
      to: outgoing_email.to,
      subject: outgoing_email.subject,
    )
  end
end
