module StateFile
  module Questions
    class NcTaxesOwedController < TaxesOwedController
      def current_time_before_payment_deadline?
        app_time <= DateTime.parse("April 11th, 2025 5pm ET")
      end
      helper_method :current_time_before_payment_deadline?
    end
  end
end
