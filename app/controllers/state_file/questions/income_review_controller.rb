module StateFile
  module Questions
    class IncomeReviewController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_sorted_vars

      def self.show?(intake)
        intake.state_file_w2s.present? ||
          intake.direct_file_data.fed_unemployment.positive? ||
          intake.state_file1099_rs.present? ||
          intake.direct_file_json_data.interest_reports.count.positive? ||
          intake.direct_file_data.fed_ssb.positive? || intake.direct_file_data.fed_taxable_ssb.positive?
      end

      def set_sorted_vars 
        @w2s = current_intake.state_file_w2s&.sort_by { |w2| [w2.employee_name, w2.employer_name] }
      end

      def update
        if @w2s.any? do |w2|
            w2.check_box14_limits = true
            !w2.valid?
          end
          flash[:alert] = I18n.t("state_file.questions.income_review.edit.invalid_w2")
          render :edit
        else
          update_for_device_id_collection(current_intake&.initial_efile_device_info)
        end
      end
    end
  end
end
