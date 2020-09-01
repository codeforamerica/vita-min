module Questions
  class WasBlindController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end
  end
end