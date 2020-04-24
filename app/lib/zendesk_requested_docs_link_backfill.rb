# Backfills Zendesk requested doc links on intake tickets. This can be
# removed once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskRequestedDocsLinkBackfill.update
#
class ZendeskRequestedDocsLinkBackfill
  def self.update
    intakes_with_ticket_no_token = Intake.where(requested_docs_token: nil).where.not(intake_ticket_id: nil)
    intakes_with_ticket_no_token.each do |intake|
      service = ZendeskIntakeService.new(intake)
      ticket = service.get_ticket(ticket_id: intake.intake_ticket_id)
      service.attach_requested_docs_link(ticket)
    end
    nil
  end
end
