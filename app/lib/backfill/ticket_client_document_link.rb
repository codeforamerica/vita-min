module Backfill
  class TicketClientDocumentLink
    include ZendeskServiceHelper
    include Rails.application.routes.url_helpers

    def call
      Intake
        .includes(:documents)
        .where.not(documents: { id: nil })
        .where.not(intake_ticket_id: nil)
        .select(:intake_ticket_id).distinct
        .pluck(:intake_ticket_id)
        .each do |ticket_id|
          ticket = get_ticket(ticket_id: ticket_id)
          if ticket
            if ticket.status == "closed"
              puts "ticket ##{ticket_id} already closed"
            else
              existing_url = ticket.fields.detect do |f|
                f.id == EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS.to_i
              end.value
              if existing_url.blank?
                ticket_url = zendesk_ticket_url(ticket_id)
                puts "Updating ticket ##{ticket_id} client document link"
                ticket.fields = { EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS => ticket_url }
                ticket.save
              else
                puts "ticket ##{ticket_id} already has document link set"
              end
            end
          else
            puts "ticket ##{ticket_id} not found in Zendesk"
          end
        end
    end

    private

    def instance
      EitcZendeskInstance
    end
  end
end
