module Ctc
  module Questions
    class ConfirmPaymentController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        @ctc_amount = ChildTaxCreditCalculator.total_advance_payment_2021(current_intake.dependents)
        @rrc_amount = current_intake.tax_return(2020).claimed_recovery_rebate_credit
        @third_stimulus_amount = current_intake.tax_return(2020).expected_recovery_rebate_credit_three
        @not_collecting = (@ctc_amount.zero? && @rrc_amount.zero? && @third_stimulus_amount.zero?) ? true : false
        super
      end

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
