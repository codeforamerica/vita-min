module StateFile
  module Questions
    class AzIncarceratedController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.ask_whether_incarcerated?
      end
    end
  end
end
