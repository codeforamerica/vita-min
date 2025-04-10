module StateFile
  module Questions
    class NjMedicalExpensesController < QuestionsController

      def self.show?(intake)
        !intake.eligibility_made_less_than_threshold?
      end
    end
  end
end
