module Hub
  module Dashboard
    class ReturnsByStatusPresenter
      attr_reader :stage
      ReturnSummary = Struct.new(:code, :value, :type, :stage)

      def initialize(current_user, clients, selected_orgs_and_sites, selected, stage)
        @current_user = current_user
        @clients = clients
        @selected_orgs_and_sites = selected_orgs_and_sites
        @selected = selected
        @stage = stage
      end

      def returns_by_status_total
        @returns_by_status_total ||= count_tax_returns_by_status.map { |row| row.num_records }.sum
      end

      def returns_by_status
        if @stage.present?
          stage, states = available_stage_and_states.find { |available_stage,| available_stage == @stage }
          @returns_by_status = states.map do |state|
            num_returns_for_status = count_tax_returns_by_status.find { |row| state.ends_with?(row.state) }
            value = num_returns_for_status ? num_returns_for_status.num_records : 0
            ReturnSummary.new(state, value, :status, stage)
          end
        else
          @returns_by_status = available_stage_and_states.map do |available_stage, available_states|
            value = count_tax_returns_by_status.filter do |row|
              available_states.include?(row.state)
            end.sum { |row| row.num_records }
            ReturnSummary.new(available_stage, value, :stage, available_stage)
          end
        end
      end

      def returns_by_status_count
        @returns_by_status_count ||= returns_by_status.sum(&:value)
      end

      def available_stage_and_states
        TaxReturnStateMachine.available_states_for(role_type: @current_user.role_type)
      end

      def percentage(value)
        count = returns_by_status_count
        return 0 if count.zero?
        (value.to_f * 100 / returns_by_status_count).round
      end

      def vita_partner_ids
        @selected_orgs_and_sites.map(&:id)
      end

      private

      def count_tax_returns_by_status
        return @count_tax_returns_by_status if @count_tax_returns_by_status
        count_tax_returns_by_status = @clients
          .joins(:tax_returns)
          .select("current_state as state, count(*) as num_records")
          .group(:state)
        @count_tax_returns_by_status = count_tax_returns_by_status.where(clients: {
          vita_partner: @selected_orgs_and_sites
        })
      end
    end
  end
end