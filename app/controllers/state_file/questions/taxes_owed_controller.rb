module StateFile
  module Questions
    class TaxesOwedController < QuestionsController

      def edit
        super
        @tax_payment_info_text = StateFile::StateInformationService.taxes_due_dates_payment_info(current_state_code)
      end

      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.negative?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end
      helper_method :taxes_owed

      def state_specific_payment_deadline
        # NOTE: Intentionally not converted to the State's timezone because this is used to display the date visually
        # Converting it from UTC to another timezone changes the day
        StateInformationService.payment_deadline_date(current_intake.state_code)
      end
      helper_method :state_specific_payment_deadline

      def current_time_before_payment_deadline?
        StateInformationService.before_payment_deadline?(app_time, current_intake.state_code)
      end
      helper_method :current_time_before_payment_deadline?
    end
  end
end
