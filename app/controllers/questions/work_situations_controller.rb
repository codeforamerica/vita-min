module Questions
  class WorkSituationsController < QuestionsController
    include AuthenticatedClientConcern

    def illustration_path
      "health-insurance.svg"
    end
  end
end