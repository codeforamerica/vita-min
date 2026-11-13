module Questions
  class HadDependentsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"
  end
end
