module Portal
  class PortalController < ApplicationController
    before_action :redirect_unless_open_for_logged_in_clients

    include AuthenticatedClientConcern

    layout "portal"

    def home
      @itin_filer_ready_to_mail = current_intake.itin_applicant? && current_intake.tax_returns.any? { |tr| tr.current_state == 'file_mailed' }
      @can_submit_additional_documents = !@itin_filer_ready_to_mail
      @document_count = current_client.documents.where(uploaded_by: current_client).count
      @tax_returns = current_client.tax_returns.order(year: :desc).to_a
      @tax_returns << PseudoTaxReturn.new(intake: current_intake) if @tax_returns.empty?
    end

    def current_intake
      current_client&.intake
    end

    private

    class PseudoTaxReturn
      attr_reader :client, :intake

      def initialize(intake:)
        @intake = intake
        @client = intake.client
      end

      def current_state
        :intake_in_progress
      end

      def year
        MultiTenantService.new(:gyr).current_tax_year
      end
    end

    def redirect_unless_open_for_logged_in_clients
      redirect_to root_path unless open_for_gyr_logged_in_clients?
    end
  end
end
