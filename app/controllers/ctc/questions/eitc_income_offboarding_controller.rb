module Ctc
  module Questions
    class EitcIncomeOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false unless Flipper.enabled?(:eitc)

        intake.had_disqualifying_non_w2_income_yes? || over_income_threshold(intake)
      end

      private

      def self.over_income_threshold(intake)
        return false unless intake.total_wages_amount

        if intake.filing_jointly?
          intake.total_wages_amount > 17_550
        else
          intake.total_wages_amount > 11_610
        end
      end

      def illustration_path
        "error.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end
