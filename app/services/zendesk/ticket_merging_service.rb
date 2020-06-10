module Zendesk
  class TicketMergingService
    include ZendeskServiceHelper

    RETURN_STATUS_ORDER =
      [
        EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS,
        EitcZendeskInstance::RETURN_STATUS_READY_FOR_QUALITY_REVIEW,
        EitcZendeskInstance::RETURN_STATUS_READY_FOR_SIGNATURE_ESIGN,
        EitcZendeskInstance::RETURN_STATUS_READY_FOR_SIGNATURE_PICKUP,
        EitcZendeskInstance::RETURN_STATUS_READY_FOR_EFILE,
        EitcZendeskInstance::RETURN_STATUS_COMPLETED_RETURNS
      ]

    INTAKE_STATUS_ORDER =
      [
        EitcZendeskInstance::INTAKE_STATUS_UNSTARTED,
        EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS,
        EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS,
        EitcZendeskInstance::INTAKE_STATUS_READY_FOR_REVIEW,
        EitcZendeskInstance::INTAKE_STATUS_IN_REVIEW,
        EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
        EitcZendeskInstance::INTAKE_STATUS_WAITING_FOR_INFO,
        EitcZendeskInstance::INTAKE_STATUS_COMPLETE
      ]

    def instance
      EitcZendeskInstance
    end

    def merge_duplicate_tickets(intake_ids)
    end

    def find_prime_ticket(ticket_ids)
      tickets = ticket_ids.map { |id| get_ticket(ticket_id: id) }
      tickets.reject! { |ticket| ticket.status == "closed" }
      tickets.sort_by { |ticket| status_index(ticket) }.last
    end

    private

    ##
    # return the index of intake_status and return_status from the respective order lists
    # e.g. a ticket with intake_status of INTAKE_STATUS_GATHERING_DOCUMENTS and
    # return status of RETURN_STATUS_READY_FOR_EFILE would return [2, 5]
    def status_index(ticket)
      [
        INTAKE_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::INTAKE_STATUS)),
        RETURN_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::RETURN_STATUS))
      ]
    end

    def ticket_status(ticket, status)
      ticket.fields.detect { |field| field.id == status.to_i }.value
    end

  end
end
