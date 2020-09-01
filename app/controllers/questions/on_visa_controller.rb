module Questions
  class OnVisaController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end
  end
end