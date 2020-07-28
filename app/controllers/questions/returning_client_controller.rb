module Questions
  class ReturningClientController < QuestionsController
    layout "application"

    def edit
      # WIP
      #
      # TODO: is there any case where we'd want to include the current intake? assuming it won't have a ticket
      duplicate_intakes = DuplicateIntakeGuard.new(current_intake).get_duplicates
      duplicate_ticket_ids = duplicate_intakes.map(&:intake_ticket_id).compact
      ticket_identifying_service = Zendesk::TicketIdentifyingService.new
      primary_ticket = ticket_identifying_service.find_primary_ticket(duplicate_ticket_ids)
      if primary_ticket
        # TODO: think about whether this should be .first - will we have multiple intakes with the same ticket id? our logic only finds the primary ticket, not the primary intake (which could be different)
        # below line is what's failing
        primary_intake = duplicate_intakes.where(intake_ticket_id: primary_ticket.id).first
        primary_intake.client_efforts.create(effort_type: :returned_to_intake, ticket_id: primary_ticket.id, made_at: Time.now)
      end
    end

    def self.show?(intake)
      DuplicateIntakeGuard.new(intake).has_duplicate?
    end

    private

    def form_class
      NullForm
    end
  end
end
