class CreateZendeskDiyIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(diy_intake_id)
    diy_intake = DiyIntake.find(diy_intake_id)

    with_raven_context(diy_intake_context(diy_intake)) do
      service = ZendeskDiyIntakeService.new(diy_intake)

      service.assign_requester
      service.create_diy_intake_ticket
    end
  end
end
