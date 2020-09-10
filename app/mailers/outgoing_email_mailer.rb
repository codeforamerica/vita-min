class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email
    mail(
      to: outgoing_email.client.email_address,
      subject: outgoing_email.subject,
    )
  end
end
