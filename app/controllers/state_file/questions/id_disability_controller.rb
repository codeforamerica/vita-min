module StateFile
  module Questions
    class IdDisabilityController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) &&
          intake.state_file1099_rs.any? { |form1099r| form1099r.taxable_amount&.to_f&.positive? } &&
          !intake.filing_status_mfs? && meets_age_requirements?(intake)
      end

      def self.meets_age_requirements?(intake)
        primary_age = intake.calculate_age(intake.primary_birth_date, inclusive_of_jan_1: true)
        if intake.filing_status_mfj? && intake.spouse_birth_date.present?
          spouse_age = intake.calculate_age(intake.spouse_birth_date, inclusive_of_jan_1: true)
          (primary_age >= 62 && primary_age < 65) || (spouse_age >= 62 && spouse_age < 65)
        else
          primary_age >= 62 && primary_age < 65
        end
      end

      def next_path
        has_disability_in_household =
          if current_intake.filing_status_mfj?
            form_params[:primary_disabled] == "yes" || form_params[:spouse_disabled] == "yes"
          else
            form_params[:primary_disabled] == "yes"
          end

        has_over_65_senior_in_household = current_intake.primary_senior? || current_intake.spouse_senior?

        if params[:return_to_review] == "y"
          if has_over_65_senior_in_household || has_disability_in_household
            StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(return_to_review: params[:return_to_review])
          else
            StateFile::Questions::IdReviewController.to_path_helper(return_to_review: params[:return_to_review])
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
