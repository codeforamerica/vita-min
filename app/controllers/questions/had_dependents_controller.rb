module Questions
  class HadDependentsController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end
  end
end