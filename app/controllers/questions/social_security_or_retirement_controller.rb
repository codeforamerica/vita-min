module Questions
  class SocialSecurityOrRetirementController < TicketedQuestionsController
    layout "yes_no_question"

    def illustration_path
      "wages.svg"
    end
  end
end
