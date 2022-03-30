module Ctc
  module Questions
    class StimulusThreeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.eip3_amount_received.nil?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
