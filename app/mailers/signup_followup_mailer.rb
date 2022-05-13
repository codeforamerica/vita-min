class SignupFollowupMailer < ApplicationMailer
  def followup(email_address:, message:)
    @body = message.email_body
    mail(
      to: email_address,
      subject: message.email_subject,
      from: message.from
    )
  end
end
