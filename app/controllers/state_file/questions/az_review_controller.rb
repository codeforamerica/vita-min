module StateFile
  module Questions
    class AzReviewController < QuestionsController
      def edit
        @refund_or_owed_amount = amount_owed_or_refunded
        @refund_or_owed_label = @refund_or_owed_amount > 0 ? I18n.t("state_file.questions.az_review.edit.your_refund") : I18n.t("state_file.questions.az_review.edit.your_tax_owed")
      end

      private

      def calculator
        calculator = current_intake.tax_calculator
        calculator.calculate
        calculator
      end

      def amount_owed_or_refunded
        calculator.refund_or_owed_amount
      end

      def form_class
        NullForm
      end
    end
  end
end
