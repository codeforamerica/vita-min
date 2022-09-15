module Ctc
  module Questions
    class EitcIncomeOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) && intake.had_disqualifying_non_w2_income_yes?
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