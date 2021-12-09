module Hub
  class CoalitionForm < Form
    include ActiveModel::Model

    attr_accessor :coalition, :name, :states

    def save
      coalition.name = name
      form_states = states.split(",").map { |abbr| States.key_for_name(abbr) } # states are comma delimited in a string, i.e. "Ohio,California"
      existing_states = coalition.state_routing_targets.pluck(:state_abbreviation)

      new_states = form_states - existing_states
      new_states.each { |state| coalition.state_routing_targets.build(state_abbreviation: state, target: @coalition) }
      coalition.state_routing_targets = coalition.state_routing_targets.select { |t| form_states.include?(t.state_abbreviation) }
      coalition.save
    end
  end
end