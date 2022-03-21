module Ctc
  module Questions
    class ConfirmPaymentController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        tax_return = current_intake.default_tax_return
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: current_intake.dependents)
        @ctc_amount = benefits.ctc_amount / 2 # total was divided by two for advance payment
        @rrc_amount = current_intake.claim_owed_stimulus_money_no? ? 0 : benefits.eip1_amount + benefits.eip2_amount
        @third_stimulus_amount = benefits.eip3_amount
        @not_collecting = @ctc_amount.zero? && @rrc_amount.zero? && @third_stimulus_amount.zero?

        # This feels like a weird place to fire this event, as it will fire each time this page is reloaded.
        # Sending it on some sort of submission status change (submission creation?) probably makes more sense.
        send_mixpanel_event(event_name: "ctc_efile_estimated_payments", data: {
            child_tax_credit_advance: @ctc_amount,
            recovery_rebate_credit: @rrc_amount,
            third_stimulus_amount: @third_stimulus_amount
        })
        super
      end

      def do_not_file
        current_intake.default_tax_return.transition_to(:file_not_filing)
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
