# zd_intake_service = ZendeskIntakeService.new(intake)
# zd_intake_service.create_intake_ticket_requester
# zd_ticket_id = zd_intake_service.create_intake_ticket
# intake.update(zendesk_ticket_id: zd_ticket_id)

class ZendeskIntakeService
  include ZendeskServiceHelper

  def initialize(intake)
    @intake = intake
  end

  def create_intake_ticket_requester
    contact_info = @intake.primary_user.contact_info_filtered_by_preferences
    find_or_create_end_user(
      @intake.primary_user.full_name,
      contact_info[:email],
      contact_info[:phone_number],
      exact_match: true
    )
  end

  def create_intake_ticket
    ticket = ZendeskAPI::Ticket.new({})
    return ticket.id
  end
end