module Questions
  class WorkSituationsController < QuestionsController
    include AuthenticatedClientConcern

    def illustration_path
      "job-count.svg"
    end
  end
end