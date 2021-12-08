module Hub
  class CoalitionForm < Form

    def initialize(coalition, form_params)
      @coalition = coalition
      @params = form_params
    end

    def save
      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        @coalition.name = @params[:name]
        return false unless @coalition.save

        existing_states = @coalition.state_routing_targets.map(&:state_name)
        form_states = @params[:states].split(",") # states are comma delimited in a string, i.e. "Ohio,California"

        new_states = form_states - existing_states
        new_states.each do |state|
          raise ActiveRecord::Rollback unless StateRoutingTarget.create(state_abbreviation: States.key_for_name(state), target: @coalition)
        end

        states_to_delete = existing_states - form_states
        state_abbrs = states_to_delete.map { |state| States.key_for_name(state) }
        StateRoutingTarget.destroy(@coalition.state_routing_targets.where(state_abbreviation: state_abbrs).pluck(:id))
      end
      true
    end
  end
end