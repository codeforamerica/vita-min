module Hub
  class VerificationAttemptsController < ApplicationController
    include FilesConcern
    include AccessControllable
    before_action :require_sign_in
    helper_method :transient_storage_url

    layout "hub"

    def index
      if params[:status]
        states = [params[:status]]
      else
        states = [:pending]
        states.push(:escalated) if current_user.admin? || current_user.client_success?
      end
      @state_counts = VerificationAttemptStateMachine.states.map do|state|
        state.in?(["pending", "escalated"]) ? [state, VerificationAttempt.in_state(state).count] : nil
      end.compact.to_h
      @verification_attempts = VerificationAttempt.includes(:client, :transitions).in_state(states).page(params[:page])
      @attempt_count = @verification_attempts.count
    end

    def show
      @verification_attempt = VerificationAttempt.includes(:client, :transitions).find(params[:id])
      @previous_verification_attempts = @verification_attempt.client.verification_attempts.where('id < ?', params[:id])
      @form = form_class.new(@verification_attempt, current_user, {})
    end

    def update
      @verification_attempt = VerificationAttempt.includes(:client, :transitions).find(params[:id])

      @form = form_class.new(@verification_attempt, current_user, form_params)
      if @form.valid?
        @form.save
        redirect_to action: :show
      else
        render :show
      end
    end

    private

    def form_class
      Hub::UpdateVerificationAttemptForm
    end

    def form_params
      params.require(form_class.form_param).permit(:note).merge(state: params[:state])
    end
  end
end