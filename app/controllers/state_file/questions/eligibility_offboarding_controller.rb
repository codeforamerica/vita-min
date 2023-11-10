module StateFile
  module Questions
    class EligibilityOffboardingController < QuestionsController
      helper_method :ineligible_reason

      def ineligible_reason
        self.class.ineligible_reason(current_intake)
      end

      def self.show?(intake)
        ineligible_reason(intake).present?
      end

      def self.ineligible_reason(intake)
        if intake.eligibility_lived_in_state_no?
          I18n.t("state_file.questions.eligibility_offboarding.edit.not_full_year_resident")
        elsif intake.class == StateFileNyIntake && intake.eligibility_yonkers_yes?
          I18n.t("state_file.questions.eligibility_offboarding.edit.yonkers")
        elsif intake.class == StateFileAzIntake && intake.eligibility_married_filing_separately_yes?
          I18n.t("state_file.questions.eligibility_offboarding.edit.married_filing_separately")
        end
      end
    end
  end
end