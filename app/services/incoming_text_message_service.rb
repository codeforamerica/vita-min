class IncomingTextMessageService
  attr_accessor :params

  OPT_OUT_KEYWORDS = %w[stop stopall unsubscribe cancel end quit].freeze
  OPT_IN_KEYWORDS  = %w[start yes unstop].freeze

  def self.process(params)
    phone_number = PhoneParser.normalize(params["From"])
    body = params["Body"].to_s.strip.downcase

    DatadogApi.increment("twilio.incoming_text_messages.received")

    # Twilio will unsubscribe/resubscribe clients when receiving an opt-in/opt-out keyword
    # but we also need to update our records to reflect this
    if opt_out_message?(body)
      handle_opt_out(phone_number)
    elsif opt_in_message?(body)
      handle_opt_in(phone_number)
    end

    clients = find_clients(phone_number)
    client_count = clients.count
    if client_count.zero?
      body = AutomatedMessage::UnmonitoredReplies.new.sms_body(support_email: Rails.configuration.email_from[:support][:gyr])
      SendOutgoingTextMessageWithoutClientJob.perform_later(phone_number: phone_number, body: body)
      DatadogApi.increment("twilio.incoming_text_messages.client_not_found")
      DatadogApi.increment("twilio.outgoing_text_messages.sent_replies_not_monitored")
      return
    end

    event_name = client_count > 1 ? "client_found_multiple" : "client_found"
    DatadogApi.increment("twilio.incoming_text_messages.#{event_name}")

    clients.find_each do |client|
      contact_record = IncomingTextMessage.create!(
        body: params["Body"],
        received_at: DateTime.now,
        from_phone_number: phone_number,
        client: client,
      )

      ProcessTextMessageAttachmentsJob.perform_later(contact_record.id, client.id, params)

      TransitionNotFilingService.run(client)

      if client.forward_message_to_intercom?
        IntercomService.create_message(
          email_address: nil,
          phone_number: contact_record.from_phone_number,
          body: contact_record.body,
          client: contact_record.client,
          has_documents: contact_record.documents.present? || params["NumMedia"].to_i > 0,
        )
        IntercomService.inform_client_of_handoff(send_email: false, send_sms: true, client: contact_record.client)
      end

      ClientChannel.broadcast_contact_record(contact_record)
    end
  end

  def self.opt_out_message?(body)
    normalized = normalize_body(body)
    OPT_OUT_KEYWORDS.any? { |kw| normalized.start_with?(kw) }
  end

  def self.opt_in_message?(body)
    normalized = normalize_body(body)
    OPT_IN_KEYWORDS.any? { |kw| normalized.start_with?(kw) }
  end

  def self.normalize_body(body)
    body.gsub(/\s+/, " ").strip
  end

  def self.find_clients(phone_number)
    consenting_clients = Client.after_consent.joins(:intake)

    consenting_clients.where(intakes: { phone_number: phone_number }).or(
      consenting_clients.where(intakes: { sms_phone_number: phone_number })
    )
  end

  def self.handle_opt_out(phone_number)
    track_last_sms_before_unsubscribe(phone_number)

    clients = find_clients(phone_number)

    clients.find_each do |client|
      client.intake&.sms_notification_opt_in_no!
    end

    CampaignContact.where(sms_phone_number: phone_number).find_each do |contact|
      contact.update!(sms_notification_opt_in: false)
    end

    DatadogApi.increment("twilio.incoming_text_messages.unsubscribe")
  end

  def self.handle_opt_in(phone_number)
    clients = find_clients(phone_number)

    clients.find_each do |client|
      client.intake&.sms_notification_opt_in_yes!
    end

    CampaignContact.where(sms_phone_number: phone_number).find_each do |contact|
      contact.update!(sms_notification_opt_in: true)
    end

    DatadogApi.increment("twilio.incoming_text_messages.resubscribe")
  end

  def self.track_last_sms_before_unsubscribe(phone_number)
    last_campaign_sms = CampaignSms.where(to_phone_number: phone_number).order(created_at: :desc).first

    last_outgoing_text_message = OutgoingTextMessage.where(to_phone_number: phone_number).order(created_at: :desc).first

    last_sms = [last_campaign_sms, last_outgoing_text_message].compact.max_by(&:created_at)

    sms_type = case last_sms
               when CampaignSms
                 "campaign"
               when OutgoingTextMessage
                 "outgoing_text_message"
               else
                 "unknown"
               end

    sms_identifier = case last_sms
                     when CampaignSms
                       last_sms.message_name
                     when OutgoingTextMessage
                       # change if we start differentiating these messages easily
                       "outgoing_text_message"
                     else
                       "unknown_sms"
                     end

    Datadog.statsd.increment("sms.unsubscribes.count", tags: ["last_sms:#{sms_identifier.to_s.parameterize.underscore}", "sms_type:#{sms_type}"])
  end
end