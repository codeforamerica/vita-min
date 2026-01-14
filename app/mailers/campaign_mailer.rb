class CampaignMailer < ApplicationMailer
  def email_message(email_address:, message_name:, locale: "en")
    message = "CampaignMessage::#{message_name.camelize}".constantize.new
    @body = message.email_body(locale: locale)

    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo

    mail(
      to: email_address,
      subject: message.email_subject(locale: locale),
      from: service.noreply_email,
      delivery_method_options: service.delivery_method_options,
      template_path: "outgoing_email_mailer",
      template_name: "user_message"
    )
  end
end
