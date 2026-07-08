module Portal
  class PortalController < ApplicationController
    before_action :redirect_unless_open_for_logged_in_clients

    include AuthenticatedClientConcern

    layout "portal"

    def home
      @tax_returns = current_client.tax_returns.order(year: :desc).to_a
      @tax_returns << PseudoTaxReturn.new(intake: current_intake, time: app_time) if @tax_returns.empty?

      current_state = current_intake&.tax_returns&.last&.current_state || 'intake_in_progress'
      send_mixpanel_event(event_name: 'client_portal_visited', data: {return_status: current_state})
    end

    def current_intake
      current_client&.intake
    end

    private

    class PseudoTaxReturn
      attr_reader :client, :intake

      def initialize(intake:, time: DateTime.now)
        @intake = intake
        @client = intake.client
        @time = time
      end

      def current_state
        :intake_in_progress
      end

      def year
        MultiTenantService.new(:gyr).current_tax_year(@time)
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
