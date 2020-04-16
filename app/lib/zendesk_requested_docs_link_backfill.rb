# Backfills Zendesk tickets with new requested docs link. This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskRequestedDocsLinkBackfill.update_link
#

class ZendeskRequestedDocsLinkBackfill
  def self.update_link
    Intake.all.each do |intake|
      return unless intake.intake_ticket_id.present?
      service = ZendeskIntakeService.new(intake)
      ticket = service.get_ticket(ticket_id: intake.intake_ticket_id)
      return unless ticket && ticket.status != "closed"

      service.attach_requested_docs_link
    end
  end
end