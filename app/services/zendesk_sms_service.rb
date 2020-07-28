class ZendeskSmsService
  include ZendeskServiceHelper

  class InboundSMSError < StandardError; end

  def initialize; end

  def instance
    EitcZendeskInstance
  end

  def handle_inbound_sms(phone_number:, sms_ticket_id:, message_body:)
    intakes = Intake.where(phone_number: phone_number)
    drop_offs = IntakeSiteDropOff.where(phone_number: phone_number)

    if intakes.empty? && drop_offs.empty?
      DatadogApi.increment("zendesk.sms.inbound.user.not_found")
      return append_comment_to_ticket(
        ticket_id: sms_ticket_id,
        comment: "This user could not be found.\ntext_user_not_found",
      )
    end

    # get all associated tickets for intakes and drop offs
    related_intake_ticket_ids = intakes.map { |intake| intake.intake_ticket_id.to_s }
    related_drop_off_ticket_ids = drop_offs.map { |drop_off| drop_off.zendesk_ticket_id }
    related_ticket_ids = (related_intake_ticket_ids + related_drop_off_ticket_ids).reject(&:blank?).uniq.sort

    if related_ticket_ids.empty?
      DatadogApi.increment("zendesk.sms.inbound.user.tickets.not_found")
      return append_comment_to_ticket(
        ticket_id: sms_ticket_id,
        comment: "This user has no associated tickets.\ntext_user_has_no_other_ticket",
      )
    end

    related_ticket_comment_body = <<~BODY
      New text message from client phone: +#{phone_number}
      View all messages at: #{ticket_url(sms_ticket_id)}
      Message:

      #{message_body}
    BODY

    related_ticket_fields = {
      EitcZendeskInstance::LINKED_TICKET => ticket_url(sms_ticket_id),
      EitcZendeskInstance::NEEDS_RESPONSE => true
    }

    related_tickets = related_ticket_ids.map {|ticket_id| get_ticket(ticket_id: ticket_id)}.compact
    related_open_tickets = related_tickets.select{|ticket| ticket.status != "closed"}

    if related_open_tickets.empty?
      DatadogApi.increment("zendesk.sms.inbound.user.tickets.open.not_found")
      return append_comment_to_ticket(
        ticket_id: sms_ticket_id,
        comment: "This user has no associated open tickets.\ntext_user_has_no_other_open_ticket",
      )
    end

    related_open_tickets.each do |related_ticket|
      append_comment_to_ticket(
        ticket_id: related_ticket.id,
        comment: related_ticket_comment_body,
        fields: related_ticket_fields
      )
    end

    # assign sms ticket to same group as most recently updated related ticket
    most_recently_updated_ticket = related_open_tickets.sort_by(&:updated_at).last

    # comment on sms ticket with related ticket id's
    # update linked ticket field with related ticket id's
    ticket_urls = related_open_tickets.map { |ticket| ticket_url(ticket.id) }
    comment_body = ticket_urls.reduce("Linked to related tickets:\n") { |body, url| body + "• #{url}\n" }
    append_comment_to_ticket(
      ticket_id: sms_ticket_id,
      comment: comment_body,
      group_id: most_recently_updated_ticket.group_id,
      fields: {
        EitcZendeskInstance::LINKED_TICKET => ticket_urls.join(",")
      },
    )

    # create client effort
    # TODO: decide whether this lives here or further up since it won't happen if all tickets are closed
    ticket_identifying_service = Zendesk::TicketIdentifyingService.new
    primary_ticket = ticket_identifying_service.find_primary_ticket(related_intake_ticket_ids)
    if primary_ticket
      # TODO: think about whether this should be .first - will we have multiple intakes with the same ticket id? our logic only finds the primary ticket, not the primary intake (which could be different)
      primary_intake = intakes.where(intake_ticket_id: primary_ticket.id).first
      primary_intake.client_efforts.create(effort_type: :sent_sms, ticket_id: primary_ticket.id, made_at: Time.now)
    end

    # send Datadog event
    DatadogApi.increment("zendesk.sms.inbound.user.tickets.open.linked")
  end
end
