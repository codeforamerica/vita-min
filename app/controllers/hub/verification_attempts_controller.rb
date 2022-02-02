module Hub
  class VerificationAttemptsController < ApplicationController
    include FilesConcern
    include AccessControllable
    before_action :require_sign_in
    helper_method :transient_storage_url

    layout "hub"

    def index
      @attempt_count = VerificationAttempt.count
    end

    def show
      @verification_attempt = VerificationAttempt.find(params[:id])
      @fraud_indicators = FraudIndicatorService.new(@verification_attempt.client).hold_indicators
    end
  end
end