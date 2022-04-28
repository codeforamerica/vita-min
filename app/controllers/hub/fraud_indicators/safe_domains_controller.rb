module Hub
  module FraudIndicators
    class SafeDomainsController < ApplicationController
      layout "hub"

      def index
        @resources = Fraud::Indicators::Domain.unscoped.where(risky: true)
      end
    end
  end
end
