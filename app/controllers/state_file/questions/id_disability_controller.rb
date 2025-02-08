module StateFile
  module Questions
    class IdDisabilityController < QuestionsController
      def self.show?(intake)
        false
      end
    end
  end
end
