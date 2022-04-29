module Hub
  module FraudIndicators
    class RiskyDomainsController < Hub::FraudIndicators::BaseController

      private

      def resource_class
        Fraud::Indicators::Domain
      end

      def default_params
        super.merge({ risky: true })
      end

      def resource_name
        "risky domain"
      end

      def page_title
        "Risky Domains List"
      end

      def form_attributes
        { name: "Domain name" }
      end

      def resources
        resource_class.unscoped.where(risky: true)
      end
    end
  end
end
