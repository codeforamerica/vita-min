class CampaignContacts::SendCampaignEmailJob < ApplicationJob
  queue_as :campaign_mailer
  include Rails.application.routes.url_helpers
  retry_on Mailgun::CommunicationError # stop if throttling??

  def perform(email_id)
    email = CampaignEmail.find(email_id)
    contact = email.campaign_contact

    response = CampaignMailer.email_message(
                        email_address: contact.email_address,
                        message_name: email.message_name,
                        locale: contact.locale.presence || "en"
                      ).deliver_now

    to_email = response.to.length > 1 ? response.to : response.to&.first
    from_email = response.from.length > 1 ? response.from : response.from&.first

    email.update(
      mailgun_message_id: response.message_id,
      to_email: to_email,
      from_email: from_email,
      subject: response.subject,
      sent_at: response.date
    )
  end

  def priority
    PRIORITY_LOW
  end
end
