module Questions
  class SelfEmploymentLossController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "reported_self_employment_loss"
    end
  end
end