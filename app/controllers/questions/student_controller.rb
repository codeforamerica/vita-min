module Questions
  class StudentController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    private

    def method_name
      "paid_post_secondary_educational_expenses"
    end
  end
end
