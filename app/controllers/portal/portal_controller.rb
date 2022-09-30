module Portal
  class PortalController < ApplicationController
    before_action :redirect_unless_open_for_logged_in_clients

    include AuthenticatedClientConcern

    layout "portal"

    def home
      @ask_for_answers = ask_for_answers?
      @itin_filer_ready_to_mail = current_intake.itin_applicant? && current_intake.tax_returns.any? { |tr| tr.current_state == 'file_mailed' }
      @can_submit_additional_documents = !@itin_filer_ready_to_mail
      @current_step = current_intake.current_step if ask_for_answers?
      @document_count = current_client.documents.where(uploaded_by: current_client).count
      @tax_returns = show_tax_returns? ? current_client.tax_returns.order(year: :desc) : []
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
      current_client.intake.completed_at? || current_client.tax_returns.map(&:current_state).any? { |state| TaxReturnStateMachine.states.index(state) >= TaxReturnStateMachine.states.index("intake_ready") }
    end

    def ask_for_answers?
      !current_client.intake.completed_at? && current_client.tax_returns.map(&:current_state).all? { |state| (TaxReturnStateMachine::STATES_BY_STAGE["intake"]).include?(state) }
    end

    def redirect_unless_open_for_logged_in_clients
      redirect_to root_path unless open_for_gyr_logged_in_clients?
    end
  end
end
