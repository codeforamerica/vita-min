module StateFile
  module Questions
    class NcSubtractionsController < QuestionsController
      before_action :set_ivars, only: [:edit, :update]

      def self.show?(intake)
        intake.positive_fed_agi?
      end

      def set_ivars
        @subtractions_limit = current_intake.calculator.subtractions_limit
      end
    end
  end
end
