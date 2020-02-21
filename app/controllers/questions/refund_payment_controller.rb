module Questions
  class RefundPaymentController < QuestionsController
    private

    def section_title
      "Personal Information"
    end

    def illustration_path
      "banking.svg"
    end
  end
end
