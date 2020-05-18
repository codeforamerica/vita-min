module Questions
  class StimulusRecommendationController < QuestionsController
    layout "application"

    def self.show?(intake)
      intake.filing_for_stimulus_yes? && intake.already_filed_yes?
    end

    private

    def form_class
      NullForm
    end
  end
end

