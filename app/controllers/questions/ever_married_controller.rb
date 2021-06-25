module Questions
  class EverMarriedController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"
  end
end
