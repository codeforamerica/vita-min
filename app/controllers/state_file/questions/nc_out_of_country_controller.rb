module StateFile
  module Questions
    class NcOutOfCountryController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(_intake)
        Flipper.enabled?(:extension_period)
      end
    end
  end
end
