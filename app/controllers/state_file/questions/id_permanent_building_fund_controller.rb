module StateFile
  module Questions
    class IdPermanentBuildingFundController < QuestionsController
      include ReturnToReviewConcern
      def self.show?(intake)
        true
      end
    end
  end
end
