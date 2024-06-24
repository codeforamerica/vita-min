module Questions
  class LifeSituationsController < QuestionsController
    include AuthenticatedClientConcern

    def illustration_path; end
  end
end