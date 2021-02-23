module Questions
  class CharitableContributionsController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "paid_charitable_contributions"
    end
  end
end
