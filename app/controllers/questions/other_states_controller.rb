module Questions
  class OtherStatesController < QuestionsController
    layout "yes_no_question"

    def edit
      @assumed_state_of_residency = States.name_for_key(current_intake.state)
      super
    end

    def section_title
      "Personal Information"
    end
  end
end
