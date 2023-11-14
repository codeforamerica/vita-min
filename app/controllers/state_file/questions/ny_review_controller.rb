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

      def next_path
        next_step = if amount_owed_or_refunded.positive?
                      StateFile::Questions::TaxRefundController
                    else
                      StateFile::Questions::TaxesOwedController
                    end
        options = { us_state: params[:us_state], action: next_step.navigation_actions.first }
        next_step.to_path_helper(options)
      end
    end
  end
end
