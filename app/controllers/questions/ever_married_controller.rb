module Questions
  class EverMarriedController < QuestionsController
    layout "yes_no_question"

    def illustration_path
      "married.svg"
    end

    def section_title
      "Personal Information"
    end
  end
end
