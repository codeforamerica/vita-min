namespace :outgoing_messages do
  def backfill_mailgun_statuses
    # The global API key, not the same as EnvironmentCredentials.dig(:mailgun, :api_key)
    mg_client = Mailgun::Client.new(ENV['MAILGUN_API_KEY'])
    OutgoingEmail
      .where(mailgun_status: 'sending')
      .where.not(message_id: nil)
      .where('created_at BETWEEN ? AND ?', 30.days.ago, 1.day.ago).each do |outgoing_email|
      events = mg_client.get("/events", {'message-id' => outgoing_email.message_id}).to_h['items']
      last_event = events.sort_by { |e| e['timestamp'] }.last
      if last_event && last_event['event'] && last_event['event'] != outgoing_email.mailgun_status
        puts "Updating status of #{outgoing_email.message_id} from #{outgoing_email.mailgun_status} to #{last_event['event']}"
        outgoing_email.update(mailgun_status: last_event['event'])
      end
    end
    nil
  end

  def backfill_twilio_statuses(limit: 1000)
    twilio_client = TwilioService.client
    OutgoingTextMessage
      .where(twilio_status: TwilioService::IN_PROGRESS_TWILIO_STATUSES)
      .where(created_at: ...4.hours.ago).order(created_at: :desc).limit(limit).each do |outgoing_text_message|

      current_status = nil
      begin
        message = twilio_client.messages(outgoing_text_message.twilio_sid).fetch
      rescue Twilio::REST::RestError
        Rails.logger.warn "Unable to fetch status for #{outgoing_text_message.twilio_sid}"
        next
      end

      if message.status != outgoing_text_message.twilio_status
        Rails.logger.warn "Updating status of #{outgoing_text_message.twilio_sid} from #{outgoing_text_message.twilio_status} to #{current_status}"
        DatadogApi.increment "twilio.outgoing_text_messages.updated_stale_status.#{current_status}"
        outgoing_text_message.update_status_if_further(current_status, error_code: message.error_code)
      end
    end
  end

  desc 'Backfill statuses of outgoing messages stuck in "sending" or "queued"'
  task backfill_statuses: [:environment] do
    backfill_mailgun_statuses
    backfill_twilio_statuses
  end
end
