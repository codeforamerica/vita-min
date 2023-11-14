module StateFile
  module Questions
    class TaxRefundController < QuestionsController

      def refund_amount
        calculator = current_intake.tax_calculator
        calculator.calculate
        calculator.refund_or_owed_amount
      end
      helper_method :refund_amount

      def form_class
        DepositTypeForm
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end
