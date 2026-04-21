class Campaign::SendCampaignEmailJob < ApplicationJob
  queue_as :campaign_mailer
  retry_on Mailgun::CommunicationError

  def perform(email_id)
    email = CampaignEmail.find(email_id)
    contact = email.campaign_contact

    return unless email && contact
    return if email.mailgun_message_id.present?
    return if max_sends_reached?(email)

    send_at = email.scheduled_send_at || Time.current
    if send_at > Time.current
      self.class.set(wait_until: send_at).perform_later(email_id)
      return
    end

    response = CampaignMailer.email_message(campaign_email: email).deliver_now

    email.update!(
      mailgun_message_id: response.message_id,
      to_email: Array(response.to).join(", "),
      from_email: Array(response.from).join(", "),
      subject: response.subject,
      sent_at: response.date
    )

    DatadogApi.increment("mailgun.campaign_emails.sent") if Rails.env.production?
  rescue Mailgun::CommunicationError, Net::ReadTimeout, Timeout::Error => e
    email.update(mailgun_status: "failed", error_code: e.class.name)
    raise
  end

  def priority
    PRIORITY_LOW
  end

  private

  def max_sends_reached?(email)
    max_sends = campaign_message_class(email).max_sends_per_contact
    return false if max_sends.nil?

    sent_count = CampaignEmail.where(
      campaign_contact_id: email.campaign_contact_id,
      message_name: email.message_name
    ).where.not(sent_at: nil).count

    sent_count >= max_sends
  end

  def campaign_message_class(email)
    "CampaignMessage::#{email.message_name.camelize}".constantize
  end
end