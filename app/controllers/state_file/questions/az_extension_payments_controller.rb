module StateFile
  module Questions
    class AzExtensionPaymentsController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:extension_period)
      end
    end
  end
end
