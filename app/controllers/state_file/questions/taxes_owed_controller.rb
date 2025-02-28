module StateFile
  module Questions
    class TaxesOwedController < QuestionsController
      include DateHelper

      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.negative?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end
      helper_method :taxes_owed

      def payment_deadline
        state_specific_payment_deadline(current_intake.state_code)
      end
      # helper_method :payment_deadline
    end
  end
end
