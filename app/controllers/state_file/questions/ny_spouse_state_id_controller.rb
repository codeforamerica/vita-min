module StateFile
  module Questions
    class NySpouseStateIdController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
