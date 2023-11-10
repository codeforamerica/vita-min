module StateFile
  module Questions
    class EligibilityOffboardingController < QuestionsController
      helper_method :ineligible_reason

      def self.show?(intake)
        return true if intake.eligibility_lived_in_state_no?

        return true if intake.class == StateFileNyIntake && intake.eligibility_yonkers_yes?
        return true if intake.class == StateFileAzIntake && intake.eligibility_married_filing_separately_yes?

        return false
      end

      def ineligible_reason
        if current_intake.eligibility_lived_in_state_no?
          I18n.t("state_file.questions.eligibility_offboarding.edit.not_full_year_resident")
        elsif current_intake.class == StateFileNyIntake && current_intake.eligibility_yonkers_yes?
          I18n.t("state_file.questions.eligibility_offboarding.edit.yonkers")
        elsif current_intake.class == StateFileAzIntake && current_intake.eligibility_married_filing_separately_yes?
          I18n.t("state_file.questions.eligibility_offboarding.edit.married_filing_separately")
        end
      end
    end
  end
end