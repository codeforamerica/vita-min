module StateFile
  module Questions
    class NjMedicalExpensesController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.nj_gross_income.positive?
      end
    end
  end
end
