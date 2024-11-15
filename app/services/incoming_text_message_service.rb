class IncomingTextMessageService
  attr_accessor :params

  def self.process(params)
    phone_number = PhoneParser.normalize(params["From"])
    DatadogApi.increment("twilio.incoming_text_messages.received")

    consenting_clients = Client.after_consent.joins(:intake)
    clients = consenting_clients.where(intakes: { phone_number: phone_number }).or(
      consenting_clients.where(intakes: { sms_phone_number: phone_number })
    )

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

    # process attachments once
    attachments = TwilioService.new.parse_attachments(params)

    clients.map do |client|
      documents = attachments.map do |attachment|
        Document.new(
          client: client,
          document_type: DocumentTypes::TextMessageAttachment.key,
          upload: {
            io: StringIO.new(attachment[:body]),
            filename: attachment[:filename],
            content_type: attachment[:content_type],
            identify: false
          }
        )
      end

      contact_record = IncomingTextMessage.create!(
        body: params["Body"],
        received_at: DateTime.now,
        from_phone_number: phone_number,
        client: client,
        documents: documents
      )

      TransitionNotFilingService.run(client)

      if client.forward_message_to_intercom?
        IntercomService.create_message(
          email_address: nil,
          phone_number: contact_record.from_phone_number,
          body: contact_record.body,
          client: contact_record.client,
          has_documents: contact_record.documents.present?
        )
        IntercomService.inform_client_of_handoff(send_email: false, send_sms: true, client: contact_record.client)
      end

      ClientChannel.broadcast_contact_record(contact_record)
    end
  end
end
