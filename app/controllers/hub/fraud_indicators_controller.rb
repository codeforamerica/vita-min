module Hub
  class FraudIndicatorsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    layout "hub"

    def index
      @fraud_indicators = Fraud::Indicator.unscoped
    end
  end
end