module StateFile
  module Questions
    class NyThirdPartyDesigneeController < QuestionsController
      include ReturnToReviewConcern
      def self.show?(intake)
        intake.direct_file_data.third_party_designee_ind == "true"
      end
    end
  end
end
