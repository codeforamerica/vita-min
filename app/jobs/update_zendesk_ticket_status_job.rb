class UpdateZendeskTicketStatusJob < ZendeskJob
  queue_as :default

  def perform(json_payload)
    @json_payload = json_payload
    return unless has_valid_intake_id? && intakes_for_ticket.present?

    # in rare cases, there may be multiple intakes with the same ticket id
    intakes_for_ticket.each do |intake|
      current_status = intake.current_ticket_status
      if current_status.nil? || ticket_status_changed?(current_status, incoming_ticket_statuses)
        # verified_change means that we already had an old TicketStatus in the database and it had
        # different status data.
        verified_change = !current_status.nil?
        new_status = intake.ticket_statuses.create(
          ticket_id: @json_payload[:ticket_id],
          verified_change: verified_change,
          **incoming_ticket_statuses
        )
        new_status.send_mixpanel_event if verified_change
      end
    end
  end

  private

  def ticket_status_changed?(current_status, intake_status: nil, return_status: nil, eip_status: nil)
    current_status.intake_status != intake_status || current_status.return_status != return_status || current_status.eip_status != eip_status
  end

  def has_valid_intake_id?
    @json_payload[:external_id].include?("intake-")
  end

  def intakes_for_ticket
    @intakes_for_ticket ||= Intake.where(intake_ticket_id: @json_payload[:ticket_id]).includes(:ticket_statuses)
  end

  def incoming_ticket_statuses
    # If a webhook event has an EIP status, skip reporting other statuses.
    if @json_payload[:eip_return_status].present?
      { eip_status: @json_payload[:eip_return_status] }
    else
      {
        intake_status: @json_payload[:digital_intake_status],
        return_status: @json_payload[:return_status],
      }
    end
  end

end
