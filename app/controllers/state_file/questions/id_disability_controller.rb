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
        if params[:return_to_review] == "y"
          if eligible_1099rs.any?
            StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(return_to_review: params[:return_to_review])
          else
            StateFile::Questions::IdReviewController.to_path_helper(return_to_review: params[:return_to_review])
          end
        else
          super
        end
      end

      private

      def eligible_1099rs
        @eligible_1099rs ||= current_intake.state_file1099_rs.select do |form1099r|
          form1099r.taxable_amount&.to_f&.positive? && person_qualifies?(form1099r)
        end
      end

      def person_qualifies?(form1099r)
        primary_tin = current_intake.primary.ssn
        spouse_tin = current_intake.spouse&.ssn

        case form1099r.recipient_ssn
        when primary_tin
          current_intake.primary_disabled_yes? || current_intake.primary_senior?
        when spouse_tin
          current_intake.spouse_disabled_yes? || current_intake.spouse_senior?
        else
          false
        end
      end

      def form_params
        params.require(:state_file_id_disability_form).permit(:mfj_disability, :primary_disabled, :spouse_disabled)
      end
    end
  end
end
