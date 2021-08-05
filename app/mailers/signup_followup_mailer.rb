class SignupFollowupMailer < ApplicationMailer
  default from: Rails.configuration.email_from[:noreply][:gyr]

  def followup(email_address, name)
    @name = name
    @subject = "Start your taxes with GetYourRefund now"
    mail(
      to: email_address,
      subject: @subject,
    )
  end
end
