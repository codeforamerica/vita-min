module Portal
  class PortalController < ApplicationController
    before_action :require_client_sign_in
    layout "portal"

    def home
      @current_step = nil
      @tax_returns = []

      if current_client.completed_intake_process?
        @tax_returns = current_client.tax_returns.order(year: :desc)
      else
        @current_step = current_client.intake.determine_current_step
      end
    end

    def current_intake
      current_client&.intake
    end

    private

    def require_client_sign_in
      redirect_to root_path unless current_client.present?
    end
  end
end
