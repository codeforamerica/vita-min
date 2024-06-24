module Questions
  class ItemizingController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def method_name
      "wants_to_itemize"
    end
  end
end
