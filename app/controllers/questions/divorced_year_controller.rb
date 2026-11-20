module Questions
  class DivorcedYearController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.divorced_yes?
    end
  end
end
