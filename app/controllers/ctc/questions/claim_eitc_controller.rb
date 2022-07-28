module Ctc
  module Questions
    class ClaimEitcController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) && !intake.home_location_puerto_rico?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
