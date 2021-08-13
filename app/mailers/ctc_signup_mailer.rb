class CtcSignupMailer < ApplicationMailer
  default from: Rails.configuration.email_from[:noreply][:ctc]

  def beta_navigation(email_address:, name:)
    @name = name
    @subject = "GetCTC Child Tax Credit Assistance now available"
    @service_type = :ctc
    mail(
      to: email_address,
      subject: @subject,
    )
  end
end
