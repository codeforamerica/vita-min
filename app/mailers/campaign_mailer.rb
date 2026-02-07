class CampaignMailer < ApplicationMailer
  def email_message(email_address:, message_name:, locale: "en", campaign_email_id: nil)
    klass = "CampaignMessage::#{message_name.camelize}".safe_constantize
    raise ArgumentError, "Unknown message_name: #{message_name}" unless klass
    message = klass.new

    @body = message.email_body(locale: locale)

    service = MultiTenantService.new(:gyr)
    email_domain = ENV.fetch("MAILGUN_OUTREACH_DOMAIN", "local.example.com")

    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      { host: service.host,
        controller: "notifications_settings",
        action: :unsubscribe_from_campaign_emails,
        locale: locale,
        _recall: {},
        email_address: signed_email(email_address) })
    inline_logo(service)

    headers_hash = {
      "X-Campaign-Email-Id" => campaign_email_id&.to_s,
      "X-Mailgun-Delivery-Time-Optimize-Period" => "72h",
    }.compact

    mail(
      to: email_address,
      subject: message.email_subject(locale: locale),
      from: "no-reply@#{email_domain}",
      delivery_method_options: {
        api_key: ENV.fetch("MAILGUN_OUTREACH_API_KEY", "fake-key-for-development"),
        domain: email_domain
      },
      template_path: "outgoing_email_mailer",
      template_name: "user_message",
      headers: headers_hash
    )
  end

  private

  def inline_logo(service)
    attachments.inline["logo.png"] = service.email_logo
  end

  def signed_email(email)
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    verifier.generate(email)
  end
end
