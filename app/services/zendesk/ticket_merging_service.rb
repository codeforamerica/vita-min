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
      ticket_ids = Intake.find(intake_ids).map(&:intake_ticket_id).compact
      primary_ticket = find_primary_ticket(ticket_ids)

      # this only happens if all tickets are closed
      # TODO: what do we do here?
      return puts "ALL TICKETS CLOSED" if !primary_ticket

      duplicate_ticket_ids = ticket_ids - [primary_ticket.id]

      # Comment on primary ticket with links to duplicates
      primary_ticket_comment_body = <<~BODY
        This client submitted multiple intakes. This is the most recent or complete ticket.
        These are the other tickets the client submitted:
        #{duplicate_ticket_list(duplicate_ticket_ids, primary_ticket)}.join("\n")
      BODY
      append_comment_to_ticket(
        ticket_id: primary_ticket.id,
        comment: primary_ticket_comment_body,
        public: false,
      )

      # Mark duplicate tickets as not filing and leave comments
      duplicate_ticket_comment_body = <<~BODY
        This client submitted multiple intakes. This ticket has been marked as "not filing" because it is a duplicate.
        The main ticket for this client is #{ticket_url(primary_ticket.id)}
      BODY
      duplicate_ticket_ids.each do |id|
        append_comment_to_ticket(
          ticket_id: id,
          comment: duplicate_ticket_comment_body,
          public: false,
          fields: {
            EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
          }
        )
      end
    end

    def find_primary_ticket(ticket_ids)
      tickets = ticket_ids.map { |id| get_ticket(ticket_id: id) }
      tickets.reject! { |ticket| ticket.status == "closed" }
      tickets.sort_by { |ticket| status_index(ticket) }.last
    end

    def find_group(id)
      client.groups.to_a.find { |g| g.id == id }
    end

    private

    def duplicate_ticket_list(ticket_ids, primary_ticket)
      primary_ticket_group = find_group(primary_ticket.group_id)

      ticket_ids.map do |id|
        ticket = get_ticket(ticket_id: id)
        duplicate_ticket_url = "*#{ticket_url(id)}"
        group = find_group(ticket.group_id)
        duplicate_ticket_url << " (assigned to #{group.name})" unless group == primary_ticket_group

        duplicate_ticket_url
      end
    end

    ##
    # return the index of intake_status and return_status from the respective order lists
    # e.g. a ticket with intake_status of INTAKE_STATUS_GATHERING_DOCUMENTS and
    # return status of RETURN_STATUS_READY_FOR_EFILE would return [2, 5]
    def status_index(ticket)
      # TODO: will this still work if intake & return statuses are reversed?
      #     # statuses: INTAKE_STATUS_NOT_FILING, RETURN_STATUS_DO_NOT_FILE, RETURN_STATUS_FOREIGN_STUDENT
      #     # are not included in the lists
      [
        INTAKE_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::INTAKE_STATUS)),
        RETURN_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::RETURN_STATUS)),
        ticket.updated_at
      ]
    end

    def ticket_status(ticket, status)
      ticket.fields.detect { |field| field.id == status.to_i }.value
    end
  end
end
