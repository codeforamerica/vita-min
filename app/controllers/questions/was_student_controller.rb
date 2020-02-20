module Questions
  class WasStudentController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end
  end
end