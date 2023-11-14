module StateFile
  module Questions
    class TaxesOwedController < QuestionsController

      def taxes_owed
        calculator = current_intake.tax_calculator
        calculator.calculate
        calculator.refund_or_owed_amount
      end
      helper_method :taxes_owed

      def form_class
        DepositTypeForm
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end

      def prev_path
        prev_path = StateFile::Questions::AzReviewController
        options = { us_state: params[:us_state], action: prev_path.navigation_actions.first }
        prev_path.to_path_helper(options)
        raise
      end
    end
  end
end
