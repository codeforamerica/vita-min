module Questions
  class HadDependentsController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end

    def next_path
      if current_intake.had_dependents_yes?
        dependents_path
      else
        super
      end
    end
  end
end