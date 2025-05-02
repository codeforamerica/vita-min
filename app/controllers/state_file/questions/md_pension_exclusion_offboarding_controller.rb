module StateFile
  module Questions
    class MdPensionExclusionOffboardingController < QuestionsController
      include OtherOptionsLinksConcern
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.should_warn_about_pension_exclusion? && intake.has_at_least_one_disabled_filer? && intake.no_proof_of_disability_submitted?
      end
    end
  end
end
