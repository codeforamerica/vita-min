module StateFile
  module Questions
    class AzExciseCreditController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        !intake.disqualified_from_excise_credit_df?
      end
    end
  end
end
