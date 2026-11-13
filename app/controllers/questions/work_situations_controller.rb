module Questions
  class WorkSituationsController < QuestionsController
    include AuthenticatedClientConcern
  end
end