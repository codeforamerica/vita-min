module Ctc
  module Questions
    class ConfirmPaymentController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        tax_return = current_intake.tax_return(2020)
        @ctc_amount = ChildTaxCreditCalculator.total_advance_payment(dependents_under_six_count: tax_return.ctc_under_6_eligible_dependent_count, dependents_six_and_over_count: tax_return.ctc_6_and_over_eligible_dependent_count)
        @rrc_amount = tax_return.claimed_recovery_rebate_credit
        @third_stimulus_amount = tax_return.expected_recovery_rebate_credit_three
        @not_collecting = @ctc_amount.zero? && @rrc_amount.zero? && @third_stimulus_amount.zero?

        send_mixpanel_event(event_name: "ctc_efile_estimated_payments", data: {
            child_tax_credit_advance: @ctc_amount,
            recovery_rebate_credit: @rrc_amount,
            third_stimulus_amount: @third_stimulus_amount
        })
        super
      end

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
