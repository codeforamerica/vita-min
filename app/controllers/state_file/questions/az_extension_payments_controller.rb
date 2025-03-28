module StateFile
  module Questions
    class AzExtensionPaymentsController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:extension_period) && after_april_16_arizona_time?
      end

      def self.after_april_16_arizona_time?
        arizona_time = Time.use_zone("Arizona") { Time.zone.now }
        arizona_time >= Time.use_zone("Arizona") { Time.zone.parse("2025-04-16 00:00:00") }
      end
    end
  end
end
