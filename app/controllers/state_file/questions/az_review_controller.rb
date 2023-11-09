module StateFile
  module Questions
    class AzReviewController < QuestionsController
      def edit
        calculated_fields = current_intake.tax_calculator.calculate
        if calculated_fields[:AZ140_LINE_79] > 0
          @refund_or_owed_label = I18n.t("state_file.questions.az_review.edit.your_refund")
          @refund_or_owed_amount = calculated_fields.fetch(:AZ140_LINE_79)
        else
          @refund_or_owed_label = I18n.t("state_file.questions.az_review.edit.your_tax_owed")
          @refund_or_owed_amount = calculated_fields.fetch(:AZ140_LINE_80)
        end
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
