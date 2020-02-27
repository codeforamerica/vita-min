module Questions
  class RefundPaymentController < QuestionsController
    private

    def section_title
      "Household Information"
    end

    def illustration_path
      "banking.svg"
    end
  end
end
