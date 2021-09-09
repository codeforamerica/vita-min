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

  def launch_announcement(email_address:, name:)
    @name = name
    subject = "Thank you for signing up to receive updates regarding GetCTC! / ¡Gracias por registrarse para recibir las actualizaciones de GetCTC!"
    @service_type = :ctc
    mail(
      to: email_address,
      subject: subject,
    )
  end
end
