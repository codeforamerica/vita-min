# Backfills Zendesk tickets with new requested docs link. This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskRequestedDocsLinkBackfill.update_link
#

class ZendeskRequestedDocsLinkBackfill
  def self.update_link
    puts "Beginning update ------------------"
    Intake.all.each do |intake|
      puts '#############################'
      next unless intake.intake_ticket_id.present?
      puts "Intake id: #{intake.id}, ticket id: #{intake.intake_ticket_id}"
      service = ZendeskIntakeService.new(intake)
      ticket = service.get_ticket(ticket_id: intake.intake_ticket_id)
      puts "Ticket status: #{ticket&.status}"
      next unless ticket && ticket.status != "closed"
      puts "Found open ticket, adding link"
      service.attach_requested_docs_link(ticket)
    end
  end
end