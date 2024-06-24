module Questions
  class SavingsOptionsController < QuestionsController
    include AuthenticatedClientConcern

    private

    def illustration_path
      "hand-holding-check.svg"
    end
  end
end
