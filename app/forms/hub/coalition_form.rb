module Hub
  class CoalitionForm < Form

    def initialize(coalition, form_params)
      @coalition = coalition
      @params = form_params
    end

    def save
      @coalition.name = @params[:name]
      return false unless @coalition.save

      existing_states = @coalition.state_routing_targets.map(&:state_name)
      form_states = @params[:states].split(",")

      new_states = form_states - existing_states
      new_states.each do |state|
        return false unless StateRoutingTarget.create(state_abbreviation: States.key_for_name(state), target: @coalition)
      end

      states_to_delete = existing_states - form_states
      states_to_delete.each do |state|
        routing_targets_to_delete = StateRoutingTarget.where(state_abbreviation: States.key_for_name(state), target: @coalition).pluck(:id)
        return false unless StateRoutingTarget.delete(routing_targets_to_delete)
      end
    end
  end
end