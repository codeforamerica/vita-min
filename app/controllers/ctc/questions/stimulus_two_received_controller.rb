module Ctc
  module Questions
    class StimulusTwoReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip2_entry_method_calculated_amount?
        return false if intake.eip2_entry_method_did_not_receive?

        true
      end

      def update
        super
        # TODO: redirect to either stimulus received or owed based on whether provided sum is greater than calculated
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
