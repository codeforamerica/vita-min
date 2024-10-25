module StateFile
  module Questions
    class IdGroceryCreditReviewController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        !intake.direct_file_data.claimed_as_dependent?
      end
    end
  end
end
