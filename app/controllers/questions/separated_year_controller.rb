module Questions
  class SeparatedYearController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.separated_yes?
    end
  end
end
