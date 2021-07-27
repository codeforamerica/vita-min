module Ctc
  module Questions
    class StimulusTwoController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip2_entry_method_calculated_amount?
        true
      end

      def update
        current_intake.update!(eip2_amount_received: 0, eip2_entry_method: :did_not_receive)
        super
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
