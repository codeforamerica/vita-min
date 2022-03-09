module Hub
  class SecurityController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "hub"

    def show
      @client = Hub::ClientsController::HubClientPresenter.new(Client.find(params[:id]))
      @duplicate_bank_client_ids = duplicate_bank_client_ids
      @most_recent_verification_attempt = @client.verification_attempts&.last
      @security_events = (
        @client.efile_security_informations + @client.recaptcha_scores
      ).sort_by(&:created_at)
    end

    private

    def duplicate_bank_client_ids
      return [] unless @client.intake.bank_account.present?
      @client.intake.bank_account.duplicates.map { |ba| ba.intake.client_id }.uniq
    end
  end
end
