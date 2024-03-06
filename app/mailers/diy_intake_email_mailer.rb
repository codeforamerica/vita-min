class DiyIntakeEmailMailer < ApplicationMailer

  def high_support_message(diy_intake:)
    @diy_intake = diy_intake
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo
    @unsubscribe_link = Rails.application.routes.url_helpers.url_for(
      {
        host: MultiTenantService.new(:gyr).host,
        controller: "notifications_settings",
        action: :unsubscribe_from_emails,
        locale: I18n.locale,
        _recall: {},
        email_address: diy_intake.email_address
      }
    )
    I18n.with_locale(diy_intake.locale) do
      mail(
        to: diy_intake.email_address,
        subject: I18n.t("high_support_mailer.subject"),
        from: service.default_email,
        delivery_method_options: service.delivery_method_options
      )
    end
  end
end
