module Hub
  class FraudIndicatorsController < Hub::BaseController
    load_and_authorize_resource class: Fraud::Indicator
    layout "hub"

    def index
      @fraud_indicators = Fraud::Indicator.unscoped
    end
  end
end