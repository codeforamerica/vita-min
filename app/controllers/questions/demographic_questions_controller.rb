module Questions
  class DemographicQuestionsController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"
  end
end