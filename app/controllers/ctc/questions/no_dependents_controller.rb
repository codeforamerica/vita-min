module Ctc
  module Questions
    class NoDependentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.dependents.none?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
