module StateFile
  module Questions
    class TaxRefundController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.positive?
      end

      def refund_amount
        current_intake.calculated_refund_or_owed_amount
      end
      helper_method :refund_amount
    end
  end
end
