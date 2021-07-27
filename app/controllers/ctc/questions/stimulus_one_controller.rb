module Ctc
  module Questions
    class StimulusOneController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_entry_method_calculated_amount?
        true
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
