module Ctc
  module Questions
    class StimulusOneController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_entry_method_calculated_amount?
        true
      end

      def update
        current_intake.update!(eip1_amount_received: 0, eip1_entry_method: :did_not_receive)
        super
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
