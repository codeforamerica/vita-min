module Portal
  class PortalController < ApplicationController
    before_action :redirect_unless_open_for_logged_in_clients

    include AuthenticatedClientConcern

    layout "portal"

    def home
      @tax_returns = current_client.tax_returns.order(year: :desc).to_a
      @tax_returns << PseudoTaxReturn.new(intake: eager_loaded_current_intake) if @tax_returns.empty?
    end

    def current_intake
      current_client&.intake
    end

    private

    def eager_loaded_current_intake
      return nil unless current_intake
      current_intake.class.includes(:client).find(current_intake.id)
    end

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

      def documents
        []
      end
    end

    def redirect_unless_open_for_logged_in_clients
      redirect_to root_path unless open_for_gyr_logged_in_clients?
    end
  end
end
