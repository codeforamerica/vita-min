module Questions
  class SeparatedController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end

    def self.show?(intake)
      intake.ever_married_yes?
    end
  end
end
