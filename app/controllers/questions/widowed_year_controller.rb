module Questions
  class WidowedYearController < QuestionsController
    layout "intake"

    def self.show?(intake)
      intake.widowed_yes?
    end

    def illustration_path
      "calendar.svg"
    end
  end
end
