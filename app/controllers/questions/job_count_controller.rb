module Questions
  class JobCountController < QuestionsController
    layout "question"

    def self.show?(intake)
      !intake.had_wages_no?
    end

    def section_title
      "Income"
    end
  end
end