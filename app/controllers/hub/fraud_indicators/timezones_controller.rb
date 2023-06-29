module Hub
  module FraudIndicators
    class TimezonesController < Hub::FraudIndicators::BaseController
      layout "hub"
      load_and_authorize_resource class: false, only: [:index]

      private

      def resource_class
        Fraud::Indicators::Timezone
      end

      def resource_name
        "timezone"
      end

      def page_title
        "Safe Timezones List"
      end

      def form_attributes
        { name: "Timezone" }
      end

      def resources
        Fraud::Indicators::Timezone.unscoped
      end
    end
  end
end
