module Hub
  class FraudIndicatorsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    layout "hub"
    load_and_authorize_resource class: Fraud::Indicator

    def index
      @fraud_indicators = Fraud::Indicator.unscoped
    end
  end
end