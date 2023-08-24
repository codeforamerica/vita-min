module Questions
  class HadDependentsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def illustration_path
      "dependents.svg"
    end
  end
end
