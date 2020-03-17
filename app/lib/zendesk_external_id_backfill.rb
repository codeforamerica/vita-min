# Backfills Zendesk `external_id`s on Drop off and Intakes. This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskExternalIdBackfill.run
#
class ZendeskExternalIdBackfill
  class << self
    include ZendeskServiceHelper

    def run
      IntakeSiteDropOff.find_each do |drop_off|
        ticket_id = drop_off.zendesk_ticket_id
        next unless ticket_id

        ticket = get_ticket(ticket_id: ticket_id)
        next unless ticket

        ticket.external_id = drop_off.external_id
        ticket.save
      end

      Intake.find_each do |drop_off|
        ticket_id = drop_off.intake_ticket_id
        next unless ticket_id

        ticket = get_ticket(ticket_id: ticket_id)
        next unless ticket

        ticket.external_id = drop_off.external_id
        ticket.save
      end
    end
  end
end
