module Hub
  class CoalitionForm < Form
    include FormAttributes

    attr_accessor :coalition

    set_attributes_for :coalition, :name
    set_attributes_for :state_routing_targets, :states

    def initialize(coalition = nil, params = {})
      @coalition = coalition
      super(params)
    end

    def save
      coalition.assign_attributes(attributes_for(:coalition))

      form_states = states.split(",")
      existing_states = coalition.state_routing_targets.pluck(:state_abbreviation)

      new_states = form_states - existing_states
      new_states.each { |state| coalition.state_routing_targets.build(state_abbreviation: state, target: coalition) }
      coalition.state_routing_targets = coalition.state_routing_targets.select { |t| form_states.include?(t.state_abbreviation) }
      coalition.save
    end
  end
end