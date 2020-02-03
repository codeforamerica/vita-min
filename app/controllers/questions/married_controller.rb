module Questions
  class MarriedController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end

    def illustration_path
      "married.svg"
    end
  end
end