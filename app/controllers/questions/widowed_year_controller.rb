module Questions
  class WidowedYearController < QuestionsController
    layout "question"

    def self.show?(intake)
      intake.widowed_yes?
    end

    def illustration_path; end
  end
end
