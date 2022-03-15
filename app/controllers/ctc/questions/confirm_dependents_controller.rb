module Ctc
  module Questions
    class ConfirmDependentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.had_dependents_yes? || intake.dependents.count > 0
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
