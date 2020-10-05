class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email

    outgoing_email.attachments.each do |attachment|
      attachments[attachment.filename.to_s] = attachment.blob.download
    end

    mail(
      to: outgoing_email.to,
      subject: outgoing_email.subject,
    )
  end
end
