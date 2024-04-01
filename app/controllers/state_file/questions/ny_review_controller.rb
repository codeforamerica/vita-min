module StateFile
  module Questions
    class NyReviewController < AuthenticatedQuestionsController
      def edit
        @invalid_w2s = StateFile::Questions::W2Controller.w2s_for_intake(current_intake)
        @refund_or_owed_amount = current_intake.calculated_refund_or_owed_amount
        @refund_or_owed_label = @refund_or_owed_amount.positive? ? I18n.t("state_file.questions.shared.review_header.your_refund") : I18n.t("state_file.questions.shared.review_header.your_tax_owed")
        @show_dependent_months_in_home = false
      end

      private

      def form_class
        NullForm
      end
    end
  end
end
