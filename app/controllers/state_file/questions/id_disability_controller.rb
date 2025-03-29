module StateFile
  module Questions
    class IdDisabilityController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) &&
          intake.state_file1099_rs.any? { |form1099r| form1099r.taxable_amount&.to_f&.positive? } &&
          !intake.filing_status_mfs? && intake.has_filer_between_62_and_65_years_old?
      end

      private

      def form_params
        params.require(:state_file_id_disability_form).permit(:mfj_disability, :primary_disabled, :spouse_disabled)
      end
    end
  end
end
