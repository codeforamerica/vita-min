module Questions
  class AdoptedChildController < QuestionsController
    include AuthenticatedClientConcern

    def self.show?(intake)
      intake.had_dependents_yes?
    end

    layout "yes_no_question"
  end
end