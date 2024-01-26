module StateFile
  module Questions
    class AzExciseCreditController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.ask_whether_incarcerated?
      end
    end
  end
end
