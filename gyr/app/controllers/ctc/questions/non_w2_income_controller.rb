module Ctc
  module Questions
    class NonW2IncomeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      def self.show?(intake, current_controller)
        return false unless current_controller.open_for_eitc_intake?
        return false if intake.dependents.any?(&:qualifying_eitc?)

        if intake.filing_jointly?
          (15_000...Efile::BenefitsEligibility::EITC_UPPER_LIMIT_JOINT).cover?(intake.total_wages_amount)
        else
          (10_000...Efile::BenefitsEligibility::EITC_UPPER_LIMIT_SINGLE).cover?(intake.total_wages_amount)
        end
      end

      def edit
        super
        @additional_income = current_intake.filing_jointly? ? Efile::BenefitsEligibility::EITC_UPPER_LIMIT_JOINT - current_intake.total_wages_amount : Efile::BenefitsEligibility::EITC_UPPER_LIMIT_SINGLE - current_intake.total_wages_amount
      end

      private

      def method_name
        'had_disqualifying_non_w2_income'
      end

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
