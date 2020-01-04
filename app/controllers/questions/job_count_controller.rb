module Questions
  class JobCountController < QuestionsController
    layout "question"

    def self.show?(intake)
      !intake.had_wages_no?
    end
  end
end