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

      signature_tr_index = @tax_returns.index { |tr| tr.current_state == 'review_signature_requested' }
      @tax_returns.insert(signature_tr_index + 1, PseudoTaxReturn.new('review_signature_requested', true))
    end

    private

    class PseudoTaxReturn
      attr_reader :current_state

      def initialize(current_state, primary_has_signed = false)
        @current_state = current_state
        @primary_has_signed = primary_has_signed
      end

      def ready_for_8879_signature?(primary_or_spouse)
        if @current_state.include?('signature_requested')
          if primary_or_spouse == TaxReturn::PRIMARY_SIGNATURE
            !@primary_has_signed
          else
            true
          end
        end
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
