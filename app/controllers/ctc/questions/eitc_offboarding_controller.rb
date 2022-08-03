module Ctc
  module Questions
    class EitcOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) && intake.claiming_eitc? && !intake.qualified_for_eitc?
      end

      private

      def illustration_path
        "error.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end