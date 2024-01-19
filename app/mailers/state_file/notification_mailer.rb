module StateFile
  class NotificationMailer < ApplicationMailer
    def user_message(notification_email:)
      service = MultiTenantService.new(:statefile)
      @body = notification_email.body
      attachments.inline['logo.png'] = service.email_logo
      mail(
        to: notification_email.to,
        subject: notification_email.subject,
        from: service.support_email,
        delivery_method_options: service.delivery_method_options
      )
    end
  end
end