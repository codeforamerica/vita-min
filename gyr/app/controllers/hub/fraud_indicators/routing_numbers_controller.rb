module Hub
  module FraudIndicators
    class RoutingNumbersController < Hub::FraudIndicators::BaseController
      before_action :require_admin

      private

      def resource_class
        Fraud::Indicators::RoutingNumber
      end

      def resource_name
        "risky routing number"
      end

      def page_title
        "Risky Routing Numbers List"
      end

      def form_attributes
        {
            routing_number: "Routing number",
            bank_name: "Bank name",
            extra_points: "Extra points"
        }
      end

      def resources
        resource_class.unscoped
      end
    end
  end
end
