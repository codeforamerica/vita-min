module Zendesk
  class TicketMergingService
    include ZendeskServiceHelper

    RETURN_STATUS_ORDER =
      [
        EitcZendeskInstance::RETURN_STATUS_UNSTARTED,
        EitcZendeskInstance::RETURN_STATUS_FOREIGN_STUDENT,
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
        EitcZendeskInstance::INTAKE_STATUS_WAITING_FOR_INFO,
        EitcZendeskInstance::INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW,
        EitcZendeskInstance::INTAKE_STATUS_COMPLETE
      ]

    def instance
      EitcZendeskInstance
    end

    def merge_duplicate_tickets(intake_ids)
      logging_prefix = "Merging Intakes #{intake_ids}"
      ticket_ids = Intake.find(intake_ids).map(&:intake_ticket_id).compact
      primary_ticket = find_primary_ticket(ticket_ids)

      # this only happens if all tickets are closed
      unless primary_ticket
        Rails.logger.info("#{logging_prefix}: Could not identify primary ticket during duplicate merging")
        return
      end

      Rails.logger.info("#{logging_prefix}: Identified primary ticket #{primary_ticket.id} during duplicate merging")

      duplicate_ticket_ids = ticket_ids - [primary_ticket.id]
      duplicate_tickets = duplicate_ticket_ids.map{ |id| get_ticket(ticket_id: id) }

      primary_intake = Intake.where(intake_ticket_id: primary_ticket.id).first

      # Update duplicate intakes with primary ticket id
      Intake.find(intake_ids).each do |intake|
        unless intake.id == primary_intake.id
          intake.update(intake_ticket_id: primary_ticket.id, primary_intake_id: primary_intake.id)

          Rails.logger.info("#{logging_prefix}: Updated duplicate intake #{intake.id} during duplicate merging")
        end
      end

      # Comment on primary ticket with links to duplicates
      update_primary_ticket(primary_ticket, duplicate_tickets)

      # Mark duplicate tickets as not filing and leave comments
      duplicate_tickets.each do |duplicate_ticket|
        update_duplicate_ticket(duplicate_ticket, primary_ticket)
      end

      Rails.logger.info("#{logging_prefix}: Completed duplicate merging")
    end

    def find_primary_ticket(ticket_ids)
      tickets = ticket_ids.map { |id| get_ticket(ticket_id: id) }
      tickets.reject! { |ticket| ticket.status == "closed" }
      tickets.sort_by { |ticket| status_index(ticket) }.last
    end

    private

    def update_primary_ticket(primary_ticket, duplicate_tickets)
      primary_ticket_comment_body = <<~BODY
        This client submitted multiple intakes. This is the most recent or complete ticket.
        These are the other tickets the client submitted:
        #{duplicate_ticket_list(duplicate_tickets, primary_ticket.group).join("\n")}
      BODY

      append_comment_to_ticket(
        ticket_id: primary_ticket.id,
        comment: primary_ticket_comment_body,
        public: false,
      )

      Rails.logger.info("Updated primary ticket #{primary_ticket.id} during duplicate merging")
    end

    # this returns a list of strings, each of which is a duplicate ticket url
    # (with the group name if it's different from the primary ticket group)
    def duplicate_ticket_list(duplicate_tickets, primary_ticket_group)
      duplicate_tickets.map do |ticket|
        duplicate_ticket_url = "• #{ticket_url(ticket.id)}"
        group = ticket.group
        duplicate_ticket_url += " (assigned to #{group.name})" unless group.id == primary_ticket_group.id

        duplicate_ticket_url
      end
    end

    def update_duplicate_ticket(duplicate_ticket, primary_ticket)
      group_note = " (assigned to #{primary_ticket.group.name})" unless primary_ticket.group.id == duplicate_ticket.group.id

      duplicate_ticket_comment_body = <<~BODY
          This client submitted multiple intakes. This ticket has been marked as "not filing" because it is a duplicate.
          The main ticket for this client is #{ticket_url(primary_ticket.id)}#{group_note}
      BODY

      append_comment_to_ticket(
        ticket_id: duplicate_ticket.id,
        comment: duplicate_ticket_comment_body,
        public: false,
        fields: {
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_NOT_FILING
        }
      )

      Rails.logger.info("Updated duplicate ticket #{duplicate_ticket.id} during duplicate merging")
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
        INTAKE_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::INTAKE_STATUS)) || -1,
        RETURN_STATUS_ORDER.index(ticket_status(ticket, EitcZendeskInstance::RETURN_STATUS)) || -1,
        ticket.updated_at
      ]
    end

    def ticket_status(ticket, status)
      ticket.fields.detect { |field| field.id == status.to_i }.value
    end
  end
end
