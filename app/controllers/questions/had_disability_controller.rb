module Questions
  class HadDisabilityController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Household Information"
    end
  end
end
