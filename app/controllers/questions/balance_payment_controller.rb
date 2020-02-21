module Questions
  class BalancePaymentController < QuestionsController
    layout "yes_no_question"

    private

    def section_title
      "Personal Information"
    end

    def illustration_path
      "banking.svg"
    end
  end
end
