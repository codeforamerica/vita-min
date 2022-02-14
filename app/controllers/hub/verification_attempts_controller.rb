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
      @verification_attempt = VerificationAttempt.includes(:client).find(params[:id])
      @form = Hub::UpdateVerificationAttemptForm.new(@verification_attempt, current_user, {})
    end

    def update
      @verification_attempt = VerificationAttempt.includes(:client).find(params[:id])

      @form = Hub::UpdateVerificationAttemptForm.new(@verification_attempt, current_user, form_params)
      if @form.valid?
        @form.save
        redirect_to action: :show
      else
        render :show
      end
    end

    private

    def form_params
      params.require(:hub_update_verification_attempt_form).permit(:body)
    end
  end
end