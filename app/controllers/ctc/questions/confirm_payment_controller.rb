module Ctc
  module Questions
    class ConfirmPaymentController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        tax_return = current_intake.tax_return(2020)
        @ctc_amount = tax_return.expected_advance_ctc_payments
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

      def do_not_file
        current_intake.tax_return(2020).transition_to(:file_not_filing)
        session.delete("intake_id")
        flash[:notice] = I18n.t('views.ctc.questions.confirm_payment.do_not_file_flash_message')
        redirect_to root_path
      end

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end
