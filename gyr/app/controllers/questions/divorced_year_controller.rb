module Questions
  class DivorcedYearController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.divorced_yes?
    end

    def illustration_path
      "calendar.svg"
    end
  end
end
