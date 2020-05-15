module Questions
  class StimulusRecommendationController < QuestionsController
    layout "question"

    private

    def illustration_path
      "filing-for-stimulus.svg"
    end

  end
end
