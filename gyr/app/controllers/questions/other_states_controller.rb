module Questions
  class OtherStatesController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.job_count&.> 0
    end

    def edit
      @assumed_state_of_residency = States.name_for_key(current_intake.state)
      super
    end

    private

    def method_name
      "multiple_states"
    end
  end
end
