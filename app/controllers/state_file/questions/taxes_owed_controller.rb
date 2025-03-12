module StateFile
  module Questions
    class TaxesOwedController < QuestionsController

      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.negative?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end
      helper_method :taxes_owed

      def payment_deadline
        StateInformationService.payment_deadline_date(current_intake.state_code)
      end
      helper_method :payment_deadline

      def before_payment_deadline?
        app_time.before?(payment_deadline.in_time_zone(StateInformationService.timezone(current_intake.state_code)))
      end
      helper_method :before_payment_deadline?
    end
  end
end
