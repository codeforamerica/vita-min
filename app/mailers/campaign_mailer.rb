class CampaignMailer < ApplicationMailer
  def email_message(email_address:, message_name:, locale: "en")
    message = "CampaignMessage::#{message_name.camelize}".constantize.new
    @body = message.email_body(locale: locale)
    service = MultiTenantService.new(:gyr)

    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      { host: service.host,
        controller: "notifications_settings",
        action: :unsubscribe_from_campaign_emails,
        locale: locale,
        _recall: {},
        email_address: signed_email(email_address) })
    inline_logo(service)

    DatadogApi.increment("mailgun.campaign_emails.sent") if Rails.env.production?

    mail(
      to: email_address,
      subject: message.email_subject(locale: locale),
      from: service.noreply_email,
      delivery_method_options: service.delivery_method_options,
      template_path: "outgoing_email_mailer",
      template_name: "user_message"
    )
  end

  private

  def inline_logo(service)
    attachments.inline['logo.png'] = service.email_logo
  end

  def signed_email(email)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    verifier.generate(email)
  end
end
