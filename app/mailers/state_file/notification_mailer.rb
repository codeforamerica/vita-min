module StateFile
  class NotificationMailer < ApplicationMailer
    def user_message(notification_email:)
      service = MultiTenantService.new(:statefile)
      @body = notification_email.body
      attachments.inline['logo.png'] = service.email_logo
      @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
        {
          host: MultiTenantService.new(:statefile).host,
          controller: "state_file/notifications_settings",
          action: :unsubscribe_email,
          locale: I18n.locale,
          _recall: {},
          email_address: notification_email.to
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