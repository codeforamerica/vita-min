module StateFile
  module Questions
    class NySpouseStateIdController < QuestionsController
      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
