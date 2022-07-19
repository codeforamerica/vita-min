module Ctc
  module Questions
    class ClaimEitcController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "yes_no_question"

      def self.show?(_intake)
        Flipper.enabled?(:eitc)
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
