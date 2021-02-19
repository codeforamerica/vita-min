class SignupFollowupMailer < ApplicationMailer
  def followup(email_address)
    mail(
      to: email_address,
      subject: "Start your taxes with GetYourRefund now",
    )
  end
end
