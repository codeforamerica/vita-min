class OutgoingEmailMailer < ApplicationMailer
  def user_message(outgoing_email:)
    @outgoing_email = outgoing_email
    attachment = outgoing_email.attachment

    is_ctc = (@outgoing_email.client.intake || Archived::Intake2021.where(client_id: @outgoing_email.client.id).first).is_ctc?
    service = MultiTenantService.new(is_ctc ? :ctc : :gyr)
    @service_type = service.service_type

    @body = outgoing_email.body
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
