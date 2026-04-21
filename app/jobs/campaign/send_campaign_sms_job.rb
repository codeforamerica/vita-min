class Campaign::SendCampaignSmsJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :campaign_sms

  def perform(text_message_id)
    text_message = CampaignSms.find(text_message_id)
    contact = text_message.campaign_contact

    return unless text_message && contact
    return if text_message.twilio_sid.present?

    begin
      message = TwilioService.new(:gyr).send_text_message(
        to: text_message.to_phone_number,
        body: text_message.body,
        status_callback: campaign_sms_webhook_url(text_message, locale: nil),
        send_at: text_message.scheduled_send_at
      )

      if message
        text_message.update(twilio_sid: message.sid)
        text_message.update_status_if_further(message.status, error_code: message.error_code)
      end
    rescue Twilio::REST::RestError => e
      if e.code == 20429
        if executions < 5
          DatadogApi.increment("twilio.campaign_sms.rate_limited")
          retry_job wait: (executions ** 2).minutes
        else
          DatadogApi.increment("twilio.campaign_sms.rate_limited.gave_up")
          text_message.update_status_if_further("twilio_error", error_code: e.code.to_s)
        end
      else
        DatadogApi.increment("twilio.campaign_sms.failure.twilio_error")
        text_message.update_status_if_further("twilio_error", error_code: e.code.to_s)
        raise unless e.code == 21211
      end
    rescue Net::OpenTimeout
      DatadogApi.increment("twilio.campaign_sms.failure.timeout")
      text_message.update_status_if_further("twilio_error", error_code: nil)
      retry_job
    end
  end

  def priority
    PRIORITY_LOW
  end
end