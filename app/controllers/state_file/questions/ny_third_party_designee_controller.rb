module StateFile
  module Questions
    class NyThirdPartyDesigneeController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.direct_file_data.third_party_designee == "true"
      end
    end
  end
end
