module UpdateIntakeEnqueuedTicketCreationMixin
  extend ActiveSupport::Concern

  included do
    after_enqueue do |job|
      intake_id = job.arguments.first
      Intake.find(intake_id).update(has_enqueued_ticket_creation: true)
    end
  end
end
