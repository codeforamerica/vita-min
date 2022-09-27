module Ctc
  module Questions
    class ClaimEitcController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake, current_controller)
        current_controller.open_for_eitc_intake? && !intake.home_location_puerto_rico?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
