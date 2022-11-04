
class OutboundEmailMailerPreview < ActionMailer::Preview
  def user_message
    OutgoingEmailMailer.user_message(outgoing_email: OutgoingEmail.last)
  end

end
