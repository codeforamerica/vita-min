class DiyIntakeEmailMailer < ApplicationMailer

  def high_support_message(diy_intake:)
    @diy_intake = diy_intake
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo

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
