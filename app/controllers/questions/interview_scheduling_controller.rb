module Questions
  class InterviewSchedulingController < TicketedQuestionsController
    layout "question"

    def edit
      super
    end

    def tracking_data
      {}
    end
  end
end
