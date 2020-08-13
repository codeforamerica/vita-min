class CreateZendeskEipIntakeTicketJob < ApplicationJob
  queue_as :default

  def perform(intake_id)
    service = Zendesk::EipService.new(Intake.find(intake_id))
    service.assign_requester
    service.create_eip_ticket
  end
end
