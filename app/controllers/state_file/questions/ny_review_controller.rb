module StateFile
  module Questions
    class NyReviewController < QuestionsController
      def edit
        calculated_fields = current_intake.tax_calculator.calculate
        if calculated_fields[:IT201_LINE_78] > 0
          @refund_or_owed_label = I18n.t("state_file.questions.ny_review.edit.your_refund")
          @refund_or_owed_amount = calculated_fields.fetch(:IT201_LINE_78)
        else
          @refund_or_owed_label = I18n.t("state_file.questions.ny_review.edit.your_tax_owed")
          @refund_or_owed_amount = calculated_fields.fetch(:IT201_LINE_80)
        end
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
