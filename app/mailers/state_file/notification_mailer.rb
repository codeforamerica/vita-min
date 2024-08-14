module StateFile
  class NotificationMailer < ApplicationMailer
    def user_message(notification_email:)
      service = MultiTenantService.new(:statefile)
      @body = notification_email.body
      attachments.inline['logo.png'] = service.email_logo

      verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
      signed_email = verifier.generate(notification_email.to)

      @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
        {
          host: MultiTenantService.new(:statefile).host,
          controller: "state_file/notifications_settings",
          action: :unsubscribe_from_emails,
          locale: I18n.locale,
          _recall: {},
          email_address: signed_email
        }
      )
      mail(
        to: notification_email.to,
        subject: notification_email.subject,
        from: service.support_email,
        delivery_method_options: service.delivery_method_options
      )
    end
  end
end