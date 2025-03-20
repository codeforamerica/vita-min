module StateFile
  module Questions
    class IdDisabilityController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) &&
          intake.state_file1099_rs.any? { |form1099r| form1099r.taxable_amount&.to_f&.positive? } &&
          !intake.filing_status_mfs? && intake.has_filer_between_62_and_65_years_old?
      end

      def next_path
        if params[:return_to_review] == "y"
          @eligible_1099rs ||= current_intake.eligible_1099rs
          if @eligible_1099rs.any?
            StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(return_to_review: params[:return_to_review])
          else
            StateFile::Questions::IdReviewController.to_path_helper
          end
        else
          super
        end
      end

      private

      def form_params
        params.require(:state_file_id_disability_form).permit(:mfj_disability, :primary_disabled, :spouse_disabled)
      end
    end
  end
end
