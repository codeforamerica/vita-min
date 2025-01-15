module StateFile
  module Questions
    class NjEitcQualifyingChildController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        Efile::Nj::NjFlatEitcEligibility.possibly_eligible?(intake)
      end
    end
  end
end
