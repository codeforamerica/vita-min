module StateFile
  module Questions
    class NcTaxesOwedController < TaxesOwedController
      def current_time_before_payment_deadline?
        StateInformationService.before_payment_deadline?(2.business_days.after(app_time), current_intake.state_code)
      end
      helper_method :current_time_before_payment_deadline?
    end
  end
end