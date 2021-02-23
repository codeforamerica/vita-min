class SignupFollowupMailer < ApplicationMailer
  default from: Rails.configuration.address_for_transactional_authentication_emails

  def followup(email_address, name)
    @name = name
    mail(
      to: email_address,
      subject: "Start your taxes with GetYourRefund now",
    )
  end
end
