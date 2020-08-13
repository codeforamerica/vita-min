class CreateZendeskEipIntakeTicketJob < ApplicationJob
  include ConsolidatedTraceHelper

  queue_as :default

  def perform(intake_id)
  end
end
