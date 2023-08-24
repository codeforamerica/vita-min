class UpdateStateRoutingTargetsService
  def self.update(target, state_abbreviations)
    state_abbreviations ||= []
    existing_states = target.state_routing_targets.pluck(:state_abbreviation) || []

    new_states = state_abbreviations - existing_states
    new_states.each { |state| target.state_routing_targets.build(state_abbreviation: state, target: target) }

    target.state_routing_targets = target.state_routing_targets.select { |t| state_abbreviations.include?(t.state_abbreviation) }
  end
end
