module StateFile
  module Questions
    class IdDisabilityController < QuestionsController

      def self.show?(intake)
        intake.show_disability_question?
      end

      private


    end
  end
end
