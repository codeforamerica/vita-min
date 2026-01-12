class CampaignMailer < ApplicationMailer
  def followup(email_address:, message:, locale: "en")
    @body = message.email_body

    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo

    mail(
      to: email_address,
      subject: message.email_subject,
      from: service.noreply_email,
      delivery_method_options: service.delivery_method_options,
      template_path: "outgoing_email_mailer",
      template_name: "user_message"
    )
  end
end
