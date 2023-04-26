module Hub
  class PortalStatesController < ApplicationController
    include AccessControllable

    layout "hub"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      @tax_returns = (TaxReturnStateMachine.states - ['intake_before_consent', 'file_rejected']).map do |state|
        PseudoTaxReturn.new(state)
      end
    end

    private

    class PseudoTaxReturn
      attr_reader :current_state

      def initialize(current_state)
        @current_state = current_state
      end

      def ready_for_8879_signature?(*args)
        @current_state.include?('signature_requested')
      end

      def year
        MultiTenantService.new(:gyr).current_tax_year
      end

      def client
        OpenStruct.new(tax_returns: [self])
      end

      def intake
        completed_at = @current_state.to_sym == :intake_in_progress ? nil : 1.day.ago
        OpenStruct.new(completed_at?: completed_at, current_step: '/hello')
      end

      def id
        999
      end

      def time_accepted
        DateTime.now
      end
    end
  end
end
