module StateFile
  module Questions
    class ExtensionPaymentsController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:extension_period)
      end
    end
  end
end
