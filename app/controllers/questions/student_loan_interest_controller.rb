module Questions
  class StudentLoanInterestController < QuestionsController
    layout "yes_no_question"

    private

    def method_name
      "paid_student_loan_interest"
    end
  end
end
