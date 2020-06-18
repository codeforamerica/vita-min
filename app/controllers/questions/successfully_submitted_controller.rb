module Questions
  class SuccessfullySubmittedController < TicketedQuestionsController
    skip_before_action :require_ticket
    append_after_action :reset_session, :track_page_view

    def edit
    end

    def include_analytics?
      true
    end
  end
end
