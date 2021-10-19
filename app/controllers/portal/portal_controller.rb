module Portal
  class PortalController < ApplicationController
    include AuthenticatedClientConcern

    layout "portal"

    def home
      @current_step = nil
      @tax_returns = []

      if completed_onboarding_process?
        @tax_returns = current_client.tax_returns.order(year: :desc)
        @can_submit_documents = true
      else
        @current_step = current_intake.current_step
        @heres_what_we_need = true
        @submit_additional_documents = @current_step.include?("/documents/")
      end

      @answered_initial_qs = completed_onboarding_process? || @current_step&.include?("/documents/")
      @shared_initial_docs = completed_onboarding_process?
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
    def completed_onboarding_process?
      current_client.intake.completed_at? || current_client.tax_returns.map(&:status_before_type_cast).any? { |status| status >= 102 }
    end
  end
end
