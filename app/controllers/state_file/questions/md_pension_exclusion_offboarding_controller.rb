module StateFile
  module Questions
    class MdPensionExclusionOffboardingController < QuestionsController
      def self.show?(intake)
        if intake.filing_status_mfj?
          if intake.primary_senior? || intake.spouse_senior?
            if intake.primary_proof_of_disability_submitted_no? || intake.spouse_proof_of_disability_submitted_no?
              return true
            end
          end
        end
        false
      end
    end
  end
end
