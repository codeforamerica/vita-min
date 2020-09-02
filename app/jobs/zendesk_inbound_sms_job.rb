class ZendeskInboundSmsJob < ZendeskJob
  queue_as :default

  def perform(sms_ticket_id:, phone_number:, message_body:)
    ZendeskSmsService.new.handle_inbound_sms(
      sms_ticket_id: sms_ticket_id,
      phone_number: phone_number,
      message_body: message_body
    )
  end
end
