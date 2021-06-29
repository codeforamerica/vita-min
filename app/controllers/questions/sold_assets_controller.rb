module Questions
  class SoldAssetsController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

  end
end