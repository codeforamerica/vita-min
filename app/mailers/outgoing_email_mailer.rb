class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email
    attachment = outgoing_email.attachment

    @body = outgoing_email.body
    @subject = outgoing_email.subject
    if attachment.present?
      attachments[attachment.filename.to_s] = attachment.blob.download
    end

    DatadogApi.increment("mailgun.outgoing_emails.sent")

    mail(
      to: outgoing_email.to,
      subject: @subject,
    )
  end
end
