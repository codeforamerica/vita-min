class DiyIntakeEmailMailer < ApplicationMailer

  def high_support_message(diy_intake_email:)
    service = MultiTenantService.new(:gyr)
    attachments.inline['logo.png'] = service.email_logo
    @first_name = diy_intake_email.diy_intake.preferred_first_name
    subject = "We’re here to help you file your taxes with File Myself!"

    mail(
      to: diy_intake_email.diy_intake.email_address,
      subject: subject,
      from: service.default_email,
      delivery_method_options: service.delivery_method_options
    )
  end
end
