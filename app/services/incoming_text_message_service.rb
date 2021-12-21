class IncomingTextMessageService
  attr_accessor :params

  def self.process(params)
    phone_number = PhoneParser.normalize(params["From"])
    DatadogApi.increment("twilio.incoming_text_messages.received")

    clients = Client.joins(:intake).where(intakes: { phone_number: phone_number}).or(Client.joins(:intake).where(intakes: { sms_phone_number: phone_number}))

    client_count = clients.count
    if client_count == 0
      DatadogApi.increment("twilio.incoming_text_messages.client_not_found")
      clients = [Client.create!(
        intake: Intake::GyrIntake.create!(
          phone_number: phone_number,
          sms_phone_number: phone_number,

          visitor_id: SecureRandom.hex(26),
          sms_notification_opt_in: "yes",
        ),
        vita_partner: VitaPartner.client_support_org,
      )]
    elsif client_count == 1
      DatadogApi.increment("twilio.incoming_text_messages.client_found")
    elsif client_count > 1
      DatadogApi.increment("twilio.incoming_text_messages.client_found_multiple")
    end

    # process attachments once
    attachments = TwilioService.parse_attachments(params)

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

      IntercomService.create_intercom_message_from_sms(contact_record, inform_of_handoff: true) if client.forward_message_to_intercom?

      ClientChannel.broadcast_contact_record(contact_record)
    end
  end
end
