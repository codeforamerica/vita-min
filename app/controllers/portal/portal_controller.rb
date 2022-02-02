module Portal
  class PortalController < ApplicationController
    include AuthenticatedClientConcern

    layout "portal"

    def home
      @ask_for_answers = ask_for_answers?

      @current_step = current_intake.current_step if ask_for_answers?
      @tax_returns = []
      @document_count = current_client.documents.where(uploaded_by: current_client).count
      @tax_returns = current_client.tax_returns.order(year: :desc) if show_tax_returns?
    end

    def current_intake
      current_client&.intake
    end

    private

    # We'll consider a client to have completed onboarding process if they've
    # a) completed_at the intake
    # b) once any of their tax returns are passed the intake stage
    # The reason we CANNOT simply rely on completed_at? is because
    # 1) many times clients "fall off" the intake flow but we complete their taxes anyway.
    # 2) don't currently (3/22/21) set completed_at on drop-off clients.
    # Once we've started preparing their taxes, we don't want to prompt them through the intake flow, but instead
    # show their tax return status information.
    def show_tax_returns?
      current_client.intake.completed_at? || current_client.tax_returns.map(&:status_before_type_cast).any? { |status| status >= 102 }
    end

    def ask_for_answers?
      !current_client.intake.completed_at? && current_client.tax_returns.map(&:status).all? { |status| (TaxReturnStatus::STATUSES_BY_STAGE["intake"]).include?(status.to_sym) }
    end
  end
end
