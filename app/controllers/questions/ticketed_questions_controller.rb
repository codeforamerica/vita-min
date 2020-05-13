module Questions
  class TicketedQuestionsController < QuestionsController
    skip_before_action :require_intake # included in :require_ticket
    before_action :require_ticket
  end
end
