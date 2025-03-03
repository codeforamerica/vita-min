module StateFile
  module Questions
    class MdPensionExclusionOffboardingController < QuestionsController
      include OtherOptionsLinksConcern
      def self.show?(intake)
        intake.filing_status_mfj? && intake.state_file1099_rs.present? && intake.has_filer_under_65? && intake.no_proof_of_disability_submitted?
      end
    end
  end
end
