module Hub
  class SecurityController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "admin"

    def show
      @client = Client.find(params[:id])
      @duplicate_bank_client_ids = duplicate_bank_client_ids
      @security_events = (
        @client.efile_security_informations + @client.recaptcha_scores
      ).sort_by(&:created_at)
    end

    private

    def duplicate_bank_client_ids
      return [] unless @client.intake.bank_account.present?
      Intake.where(id: @client.intake.bank_account.duplicates.pluck(:intake_id)).pluck(:client_id)
    end
  end
end
