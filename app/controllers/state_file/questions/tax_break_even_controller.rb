module StateFile
  module Questions
    class TaxBreakEvenController < QuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.zero?
      end
      def refund_amount
        current_intake.calculated_refund_or_owed_amount
      end
      helper_method :refund_amount
    end
  end
end
