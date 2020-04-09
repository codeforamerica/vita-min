class ZendeskSmsService
  include ZendeskServiceHelper

  class InboundSMSError < StandardError; end

  def initialize; end

  def instance
    EitcZendeskInstance
  end

  def handle_inbound_sms(phone_number:, sms_ticket_id:, message_body:)
    users = User.where(phone_number: phone_number)
    drop_offs = IntakeSiteDropOff.where(phone_number: phone_number)

    if users.empty? && drop_offs.empty?
      return append_comment_to_ticket(
        ticket_id: sms_ticket_id,
        comment: "This user could not be found.\ntext_user_not_found",
      )
    end

    # get all associated tickets for intakes and drop offs
    related_ticket_ids = (users.map { |user| user.intake.intake_ticket_id.to_s } +
        drop_offs.map { |drop_off| drop_off.zendesk_ticket_id }).reject(&:blank?).uniq.sort

    if related_ticket_ids.empty?
      return append_comment_to_ticket(
        ticket_id: sms_ticket_id,
        comment: "This user has no associated tickets.\ntext_user_has_no_other_ticket",
      )
    end

    related_ticket_comment_body = <<~BODY
      New text message from client phone: #{phone_number}
      To respond to the client via text message, go to this ticket: #{ticket_url(sms_ticket_id)}

      ---------------------------

      Message:

      #{message_body}
    BODY

    related_ticket_fields = {
      EitcZendeskInstance::LINKED_TICKET => ticket_url(sms_ticket_id),
      EitcZendeskInstance::NEEDS_RESPONSE => true
    }

    related_tickets = []
    related_ticket_ids.each do |related_ticket_id|
      related_tickets << get_ticket(ticket_id: related_ticket_id)
      append_comment_to_ticket(
        ticket_id: related_ticket_id,
        comment: related_ticket_comment_body,
        fields: related_ticket_fields
      )
    end

    # comment on sms ticket with related ticket id's
    # update linked ticket field with related ticket id's
    ticket_urls = related_ticket_ids.map { |id| ticket_url(id) }
    comment_body = ticket_urls.reduce("Linked to related tickets:\n") { |body, url| body + "• #{url}\n" }
    append_comment_to_ticket(
      ticket_id: sms_ticket_id,
      comment: comment_body,
      fields: {
        EitcZendeskInstance::LINKED_TICKET => ticket_urls.join(",")
      }
    )

    # assign sms ticket to same group as most recently updated related ticket
    most_recently_updated_ticket = related_tickets.sort_by(&:updated_at).last
    assign_ticket_to_group(ticket_id: sms_ticket_id, group_id: most_recently_updated_ticket.group_id)
  end

  private

  def ticket_url(ticket_id)
    "https://#{EitcZendeskInstance::DOMAIN}.zendesk.com/agent/tickets/#{ticket_id}"
  end
end
