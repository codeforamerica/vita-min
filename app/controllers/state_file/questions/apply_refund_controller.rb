module StateFile
  module Questions
    class ApplyRefundController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:extension_period)
      end
    end
  end
end
