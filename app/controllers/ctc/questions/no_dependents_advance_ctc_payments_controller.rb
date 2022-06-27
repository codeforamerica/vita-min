module Ctc
  module Questions
    class NoDependentsAdvanceCtcPaymentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.dependents.none?(&:qualifying_ctc?)
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
