class CtcSignupMailer < ApplicationMailer
  def launch_announcement(email_address:, name:)
    @name = name
    subject = "Thank you for signing up to receive updates regarding GetCTC! / ¡Gracias por registrarse para recibir las actualizaciones de GetCTC!"
    service = MultiTenantService.new(:ctc)
    attachments.inline['logo.png'] = service.email_logo

    mail(
      to: email_address,
      subject: subject,
      from: service.noreply_email,
      delivery_method_options: service.delivery_method_options,
    )
  end
end
