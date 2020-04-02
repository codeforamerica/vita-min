# Backfills Zendesk `notification_opt_ins` on intake tickets. This can be
# removed once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskNotificationOptInBackfill.update_zendesk_tickets
#
class ZendeskNotificationOptInBackfill
  def self.update_zendesk_tickets
    Intake.find_each do |intake|
      next unless intake.intake_ticket_id.present?

      service = ZendeskIntakeService.new(intake)
      ticket = service.get_ticket(ticket_id: intake.intake_ticket_id)
      next unless ticket

      field_id = service.instance::COMMUNICATION_PREFERENCES
      field_value = service.new_ticket_fields[field_id]
      ticket.fields = { field_id => field_value }
      ticket.save
    end
  end
end
