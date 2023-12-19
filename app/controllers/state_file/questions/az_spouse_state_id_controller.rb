module StateFile
  module Questions
    class AzSpouseStateIdController < AuthenticatedQuestionsController

      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
