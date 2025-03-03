module StateFile
  module Questions
    class MdPensionExclusionOffboardingController < QuestionsController
      include OtherOptionsLinksConcern
      def self.show?(intake)
        true
      end
    end
  end
end
