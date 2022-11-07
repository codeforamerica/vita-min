class OutgoingEmailMailerPreview < ActionMailer::Preview
  def user_message
    outgoing_email = params[:outgoing_email] || OutgoingEmail.first
    OutgoingEmailMailer.notify(outgoing_email: outgoing_email)
  end
end