module Questions
  class JobCountController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"
  end
end
