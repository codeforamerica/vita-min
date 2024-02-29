module StateFile
  module Questions
    class NyThirdPartyDesigneeController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
