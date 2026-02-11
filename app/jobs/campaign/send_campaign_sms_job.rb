class Campaign::SendCampaignSmsJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :campaign_sms

  def perform(text_message_id)
    return if Flipper.enabled?(:cancel_campaign_emails)

    text_message = CampaignTextMessage.find(text_message_id)
    contact = text_message.campaign_contact

    return unless text_message && contact
    return if text_message.twilio_sid.present?

    send_at = text_message.scheduled_send_at || Time.current
    if send_at > Time.current
      self.class.set(wait_until: send_at).perform_later(text_message_id)
      return
    end

    begin
      message = TwilioService.new(:gyr).send_text_message(
        to: text_message.to_phone_number,
        body: text_message.body,
        status_callback: outgoing_text_message_url(text_message, locale: nil), #do i need to change this
        outgoing_text_message: text_message
      )

      if message
        text_message.update(
          twilio_sid: message.sid,
          sent_at: DateTime.now
        )
        text_message.update_status_if_further(message.status, error_code: message.error_code)
      end
    rescue Net::OpenTimeout
      DatadogApi.increment("twilio.outgoing_text_message.failure.timeout")
      text_message.update_status_if_further("twilio_error", error_code: nil)
      retry_job
    end
  end

  def priority
    PRIORITY_LOW
  end
end