module Questions
  class PaidAlimonyController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_married_yes?
    end

    def illustration_path
      "alimony.svg"
    end
  end
end
