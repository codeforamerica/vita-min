module StateFile
  module Questions
    class BaseReviewController < QuestionsController
      def edit
        @refund_or_owed_amount = current_intake.calculated_refund_or_owed_amount
        @refund_or_owed_label = @refund_or_owed_amount.positive? ? I18n.t("state_file.questions.shared.review_header.your_refund") : I18n.t("state_file.questions.shared.review_header.your_tax_owed")
        @income_documents_present = income_documents_present?
      end

      private

      def income_documents_present?
        current_intake.state_file1099_rs.present? ||
          current_intake.state_file_w2s.present? ||
          current_intake.direct_file_json_data.interest_reports.count.positive? ||
          current_intake.direct_file_data.fed_unemployment.positive? ||
          current_intake.direct_file_data.fed_ssb.positive? || 
          current_intake.direct_file_data.fed_taxable_ssb.positive?
      end

      def form_class
        NullForm
      end
    end
  end
end
