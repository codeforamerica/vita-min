module Questions
  class DisasterLossController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "had_disaster_loss"
    end
  end
end