module Hub
  class PortalStatesController < Hub::BaseController
    load_and_authorize_resource class: false

    def index
      @tax_returns = (TaxReturnStateMachine.states - ['intake_before_consent']).map do |state|
        PseudoTaxReturn.new(state)
      end

      intake_incomplete_tr_index = @tax_returns.index { |tr| tr.current_state == 'intake_in_progress' }
      @tax_returns.insert(intake_incomplete_tr_index + 1, PseudoTaxReturn.new('intake_in_progress', current_step: "/documents"))

      signature_tr_index = @tax_returns.index { |tr| tr.current_state == 'review_signature_requested' }
      @tax_returns.insert(
        signature_tr_index + 1,
        PseudoTaxReturn.new('review_signature_requested', primary_has_signed: false, unsigned_8879s: true),
        PseudoTaxReturn.new('review_signature_requested', primary_has_signed: true, unsigned_8879s: true)
      )
    end

    private

    class PseudoTaxReturn
      attr_reader :current_state

      def initialize(current_state, options = {})
        @current_state = current_state
        @options = options
        @unsigned_8879s = options[:unsigned_8879s] || false
        @primary_has_signed = options[:primary_has_signed] || false
        @current_step = options[:current_step] || "/en"
      end

      def _description
        lines = ["State: #{@current_state}"]
        lines << "options: #{@options.inspect}" if @options.present?
        lines.join(', ')
      end

      def ready_for_8879_signature?(primary_or_spouse)
        if @current_state == "review_signature_requested" && @unsigned_8879s
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

      def documents
        []
      end

      def intake
        OpenStruct.new(current_step: @current_step)
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
