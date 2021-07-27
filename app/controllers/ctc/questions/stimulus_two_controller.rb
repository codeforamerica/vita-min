module Ctc
  module Questions
    class StimulusTwoController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip2_entry_method_calculated_amount?

        true
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
