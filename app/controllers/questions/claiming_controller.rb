module Questions
  class ClaimingController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def method_name
      "claimed_by_another"
    end
  end
end
