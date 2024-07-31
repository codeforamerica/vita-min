class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email
    attachment = outgoing_email.attachment
    service = MultiTenantService.new(:gyr)
    @service_type = service.service_type

    @body = outgoing_email.body

    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: outgoing_email.to
      }
    )
    @subject = outgoing_email.subject
    if attachment.present?
      attachments[attachment.filename.to_s] = attachment.blob.download
    end

    DatadogApi.increment("mailgun.outgoing_emails.sent")

    attachments.inline['logo.png'] = service.email_logo
    mail(
      to: outgoing_email.to,
      subject: @subject,
      from: service.default_email,
      delivery_method_options: service.delivery_method_options
    )
  end

end
