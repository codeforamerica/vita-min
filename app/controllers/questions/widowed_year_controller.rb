module Questions
  class WidowedYearController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.widowed_yes?
    end
  end
end
