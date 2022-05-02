module Hub
  module FraudIndicators
    class SafeDomainsController < ApplicationController
      layout "hub"

      private

      def resource_class
        Fraud::Indicators::Domain
      end

      def default_params
        super.merge({ safe: true })
      end

      def resource_name
        "safe domain"
      end

      def page_title
        "Safe Domains List"
      end

      def form_attributes
        { name: "Domain name" }
      end

      def resources
        resource_class.unscoped.where(safe: true)
      end
    end
  end
end
