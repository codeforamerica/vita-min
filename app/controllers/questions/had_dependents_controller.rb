module Questions
  class HadDependentsController < AuthenticatedIntakeController
    layout "yes_no_question"

    def next_path
      if current_intake.had_dependents_yes?
        dependents_path
      else
        super
      end
    end

    def illustration_path
      "dependents.svg"
    end
  end
end