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

      private

      def form_params
        params.require(:state_file_id_disability_form).permit(:mfj_disability, :primary_disabled, :spouse_disabled)
      end
    end
  end
end
