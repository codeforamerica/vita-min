module StateFile
  module Questions
    class AzReviewController < QuestionsController
      def edit
        @refund_or_owed_amount = current_intake.calculated_refund_or_owed_amount
        @refund_or_owed_label = @refund_or_owed_amount.positive? ? I18n.t("state_file.questions.az_review.edit.your_refund") : I18n.t("state_file.questions.az_review.edit.your_tax_owed")
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
