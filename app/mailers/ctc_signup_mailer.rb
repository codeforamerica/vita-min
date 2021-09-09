class CtcSignupMailer < ApplicationMailer
  def launch_announcement(email_address:, name:)
    @name = name
    subject = "Thank you for signing up to receive updates regarding GetCTC! / ¡Gracias por registrarse para recibir las actualizaciones de GetCTC!"
    ctc_service = MultiTenantService.new(:ctc)
    mail(
      to: email_address,
      subject: subject,
      from: ctc_service.noreply_email,
      delivery_method_options: ctc_service.delivery_method_options,
    )
  end
end
