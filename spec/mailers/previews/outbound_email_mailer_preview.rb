# Preview all emails at http://localhost:3000/rails/mailers/outbound_email_mailer
class OutboundEmailMailerPreview < ActionMailer::Preview
  def user_message
    OutgoingEmailMailer.user_message(outgoing_email: OutgoingEmail.last)
  end
end
