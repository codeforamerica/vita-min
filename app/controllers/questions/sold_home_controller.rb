module Questions
  class SoldHomeController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "sold_a_home"
    end
  end
end
