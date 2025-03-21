module StateFile
  module Questions
    class NjMedicalExpensesController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        !intake.eligibility_made_less_than_threshold?
      end
    end
  end
end
