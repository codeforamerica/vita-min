module StateFile
  class StateInformationService
    ACTIVE_STATES = ["az", "ny"].freeze

    def state_code_to_name_map
      ACTIVE_STATES.reduce({}) do |acc, state_abbrev|
        acc[state_abbrev] = States.name_for_key(state_abbrev.upcase)
      end
    end
  end
end
