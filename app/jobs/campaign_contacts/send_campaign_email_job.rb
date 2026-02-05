class CampaignContacts::SendCampaignEmailJob < ApplicationJob
  queue_as :campaign_mailer
  retry_on Mailgun::CommunicationError,
           Net::ReadTimeout,
           Timeout::Error,
           wait: :exponentially_longer,
           attempts: 8

  def perform(email_id)
    email = CampaignEmail.find_by(id: email_id)
    return unless email

    return if email.mailgun_message_id.present? || email.sent_at.present?

    contact = email.campaign_contact

    response = CampaignMailer.email_message(
      email_address: contact.email_address,
      message_name: email.message_name,
      locale: contact.locale.presence || "en"
    ).deliver_now

    email.update!(
      mailgun_message_id: response.message_id,
      to_email: Array(response.to).join(", "),
      from_email: Array(response.from).join(", "),
      subject: response.subject,
      sent_at: response.date
    )
  rescue Mailgun::CommunicationError, Net::ReadTimeout, Timeout::Error => e
    email.update(mailgun_status: "failed", error_code: e.class.name)
    raise
  end


  def priority
    PRIORITY_LOW
  end
end
