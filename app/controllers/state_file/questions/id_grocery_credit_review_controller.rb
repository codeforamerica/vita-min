module StateFile
  module Questions
    class IdGroceryCreditReviewController < QuestionsController
      include ReturnToReviewConcern

      def grocery_credit_amount
        current_intake.calculator.grocery_credit_amount
      end
      helper_method :grocery_credit_amount

      def self.show?(intake)
        !intake.direct_file_data.claimed_as_dependent? && intake.calculator.grocery_credit_amount.positive?
      end
    end
  end
end
