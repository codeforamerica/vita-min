module StateFile
  class StateInformationService
    ACTIVE_STATES = ["az", "ny"].freeze

    class << self
      def state_code_to_name_map
        ACTIVE_STATES.reduce({}) do |acc, state_abbrev|
          state_name = States.name_for_key(state_abbrev.upcase)
          acc[state_abbrev] = state_name if state_name
          acc
        end
      end
    end
  end
end
